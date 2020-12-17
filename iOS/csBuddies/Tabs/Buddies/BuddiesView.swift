//
//  BuddiesView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/18/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase

struct BuddiesView: View {
    @EnvironmentObject var global: Global
    
    let openingTitle = "Just a moment please!"
    let openingMessage = "Are you getting to know new coders in this app?"
    let yesTitle = "We are super glad to hear that!   :)"
    let yesMessage = "Would you mind rating us on the App Store?"
    let noTitle = "We are so sorry to hear that.   :("
    let noMessage = "Would you mind providing feedback so we can improve this app for you?"
    
    let openingSayYes = "Yes, I am!"
    let openingSayNo = "Not really."
    let afterOpeningSayYes = "Sure, take me there!"
    let afterOpeningSayNo = "No, don't ask again."
    
    @State private var mustGetBuddies = true
    @State private var buddies = [UserPreviewData]()
    @State private var bottomLastVisitTime = Date()
    @State private var bottomSignUpTime = Date()
    @State private var isLoading = false
    @State private var isRefreshing = false
    @State private var canLoadMore = false

    @State private var refreshCounter = 0

    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            opening,
            yes,
            no
    }

    @State var activeSheet: Sheets?
    enum Sheets: Identifiable {
        var id: Int { self.hashValue }
        case
            buddiesFilter
    }

    var body: some View {
        ZStack {
            if mustGetBuddies {
                Spacer()
                    .onAppear {
                        mustGetBuddies = false
                        bottomLastVisitTime = global.getUtcTime()
                        bottomSignUpTime = global.getUtcTime()
                        buddies.removeAll()
                        refreshCounter += 1
                        getBuddies()
                    }
            }
            
            List {
                if global.announcementText.count != 0 {
                    HStack {
                        NavigationLinkNoArrow(destination:
                                                WebView(request: URLRequest(url: URL(string: global.announcementLink)!))
                                                .navigationBarTitle(global.announcementLink, displayMode: .inline)) {
                            HStack {
                                Text(global.announcementText.replacingOccurrences(of: "\\n", with: "\n"))
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.white)
                                Spacer()
                            }
                        }
                        
                        Image(systemName: "xmark")
                            .imageScale(.large)
                            .foregroundColor(Color.white)
                            .onTapGesture {
                                global.announcementText = ""
                            }
                    }
                    .listRowBackground(Color.orange)
                }
                
                // Indices will not update the views when more profiles are loaded.
                // Using enumerated or zip will require ad banner to stick to a profile using Vstack.
                // Also, using enumerated or zip will cause a glitch when more profiles are loaded after clicking on a banner ad.
                // Admob Native Ads View slows down the app, so stop showing them at some point.
                ForEach(buddies) { userPreviewData in
                    if !global.blocks.contains(where: { $0.userId == userPreviewData.userId }) {
                        BuddiesPreviewView(userPreviewData: userPreviewData, myImage: global.smallImage)
                    }

                    if buddies.firstIndex(where: { $0.id == userPreviewData.id })! % 10 == 9 &&
                        buddies.firstIndex(where: { $0.id == userPreviewData.id })! < 500 &&
                        !global.isPremium {
                        AdmobNativeAdsBuddiesView()
                    }
                }
                // Do not use .id(UUID()) to prevent calling PHP on each tab change.

                HStack {
                    Spacer()
                    if isLoading {
                        LottieView(name: "load", size: 300, padding: -50, mustLoop: true)
                    } else if buddies.count == 0 {
                        LottieView(name: "noData", size: 300, padding: -50)
                    } else {
                        Text("End")
                            .onAppear {
                                if canLoadMore {
                                    getBuddies()
                                }
                            }
                    }
                    Spacer()
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .navigationBarTitle("Buddies")
        .pullToRefresh(isShowing: $isRefreshing) {
            bottomLastVisitTime = global.getUtcTime()
            bottomSignUpTime = global.getUtcTime()
            buddies.removeAll()
            refreshCounter += 1
            getBuddies()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack { // Having at least 2 views inside HStack is necessary to make Image larger.
                    Spacer()
                    Button(action: {
                        setNewFilterVars()
                        activeSheet = .buddiesFilter
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.largeTitle)
                    }
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            // Do not wrap the sheets in another view like VStack or the sheets may not be dismissed properly when global variables are changed.
            switch sheet {
            case .buddiesFilter:
                NavigationView {
                    BuddiesFilterView(mustGetBuddies: $mustGetBuddies)
                        .environmentObject(globalObject)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .opening:
                return Alert(title: Text(openingTitle), message: Text(openingMessage), primaryButton: .destructive(Text(openingSayNo), action: {
                    activeAlert = .no
                }), secondaryButton: .default(Text(openingSayYes), action: {
                    activeAlert = .yes
                }))
            case .yes:
                return Alert(title: Text(yesTitle), message: Text(yesMessage), primaryButton: .default(Text(afterOpeningSayYes), action: {
                    global.linkToReview()
                }), secondaryButton: .destructive(Text(afterOpeningSayNo)))
            case .no:
                return Alert(title: Text(noTitle), message: Text(noMessage), primaryButton: .default(Text(afterOpeningSayYes), action: {
                    global.linkToReview()
                }), secondaryButton: .destructive(Text(afterOpeningSayNo)))
            }
        }
    }
    
    // Reset new filter variables here instead of onAppear of BuddiesFilterView since it may be navigated from other views.
    func setNewFilterVars() {
        global.newBuddiesFilterGenderIndex = global.buddiesFilterGenderIndex
        global.newBuddiesFilterMinAge = global.buddiesFilterMinAge
        global.newBuddiesFilterMaxAge = global.buddiesFilterMaxAge
        global.newBuddiesFilterCountryIndex = global.buddiesFilterCountryIndex
        global.newBuddiesFilterInterests = global.buddiesFilterInterests
        global.newBuddiesFilterSortIndex = global.buddiesFilterSortIndex
    }
    
    func getBuddies() {
        if isLoading {
            return
        }
        isLoading = true
        canLoadMore = true
        
        let postString =
            "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "gender=\(global.buddiesFilterGenderIndex - 1)&" +
            "minAge=\(global.buddiesFilterMinAge)&" +
            "maxAge=\(global.buddiesFilterMaxAge)&" +
            "country=\(global.buddiesFilterCountryIndex - 1)&" +
            "interests=\(global.buddiesFilterInterests.toInterestsString().addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "sort=\(global.buddiesFilterSortIndex)&" +
            "bottomLastVisitTime=\(bottomLastVisitTime.toString())&" +
            "bottomSignUpTime=\(bottomSignUpTime.toString())"
        global.runPhp(script: "getFilteredBuddies", postString: postString) { json in
            if json.count <= 1 {
                isLoading = false
                isRefreshing = false
                canLoadMore = false
                return
            }
            
            for i in 1...json.count - 1 {
                let row = json[String(i)] as! NSDictionary
                let userPreviewData = UserPreviewData(
                    userId: row["buddyId"] as! String,
                    username: row["username"] as! String,
                    birthday: (row["birthday"] as! String).toDate(fromFormat: "yyyy-MM-dd"),
                    genderIndex: row["gender"] as! Int,
                    intro: row["intro"] as! String,
                    hasGitHub: row["hasGitHub"] as! Bool,
                    hasLinkedIn: row["hasLinkedIn"] as! Bool,
                    isOnline: global.isOnline(lastVisitTimeAny: row["lastVisitTime"]),
                    lastVisitTime: (row["lastVisitTime"] as! String).toDate())
                buddies.append(userPreviewData)
            }
            
            let lastRow = json[String(json.count)] as! NSDictionary
            bottomLastVisitTime = (lastRow["bottomLastVisitTime"] as! String).toDate()
            bottomSignUpTime = (lastRow["bottomSignUpTime"] as! String).toDate()
            
            isRefreshing = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Prevent calling PHP twice on each load.
                isLoading = false
            }
            
            if !global.hasAskedReview &&
                refreshCounter > 3 &&
                global.getUtcTime().timeIntervalSince(global.firstLaunchTime) > 60 * 60 * 24 * 1 {
                global.hasAskedReview = true
                activeAlert = .opening
            }
        }
    }
}

struct BuddiesView_Previews: PreviewProvider {
    static var previews: some View {
        BuddiesView()
            .environmentObject(globalObject)
    }
}
