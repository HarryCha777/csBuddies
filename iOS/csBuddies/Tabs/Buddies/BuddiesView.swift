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
    
    @State private var buddyIds = [String]()
    @State private var mustGetBuddies = true
    @State private var isLoading = false
    @State private var canLoadMore = false
    @State private var bottomLastVisitedAt = Date()
    @State private var bottomSignedUpAt = Date()
    
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
        List {
            ForEach(buddyIds, id: \.self) { buddyId in
                if !global.blockedBuddyIds.contains(buddyId) {
                    UserPreviewView(userId: buddyId)
                }
            }
            // Do not use .id(UUID()) to prevent calling PHP on each tab change.
            
            InfiniteScrollView(isLoading: isLoading, isEmpty: buddyIds.count == 0, canLoadMore: canLoadMore, loadMore: getBuddies)
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Buddies")
        .refresh(isRefreshing: $mustGetBuddies, isRefreshingBool: mustGetBuddies) {
            bottomLastVisitedAt = global.getUtcTime()
            bottomSignedUpAt = global.getUtcTime()
            buddyIds.removeAll()
            refreshCounter += 1
            getBuddies()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack { // Having at least 2 views inside HStack is necessary to make Image larger.
                    Spacer()
                    Button(action: {
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
    
    func getBuddies() {
        if isLoading {
            return
        }
        isLoading = true
        canLoadMore = true
        
        global.getTokenIfSignedIn { token in
            let postString =
                "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "token=\(token.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "gender=\(global.buddiesFilterGenderIndex - 1)&" +
                "minAge=\(global.buddiesFilterMinAge)&" +
                "maxAge=\(global.buddiesFilterMaxAge)&" +
                "country=\(global.buddiesFilterCountryIndex - 1)&" +
                "interests=\(global.buddiesFilterInterests.toInterestsString().addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "sort=\(global.buddiesFilterSortIndex)&" +
                "bottomLastVisitedAt=\(bottomLastVisitedAt.toString())&" +
                "bottomSignedUpAt=\(bottomSignedUpAt.toString())"
            global.runPhp(script: "getTabBuddies", postString: postString) { json in
                if json.count <= 1 {
                    mustGetBuddies = false
                    isLoading = false
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
                        countryIndex: row["country"] as! Int,
                        intro: row["intro"] as! String,
                        lastVisitedAt: (row["lastVisitedAt"] as! String).toDate())
                    userPreviewData.updateClientData()
                    buddyIds.append(userPreviewData.userId)
                }
                
                let lastRow = json[String(json.count)] as! NSDictionary
                bottomLastVisitedAt = (lastRow["bottomLastVisitedAt"] as! String).toDate()
                bottomSignedUpAt = (lastRow["bottomSignedUpAt"] as! String).toDate()
                
                mustGetBuddies = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Prevent calling PHP twice on each load.
                    isLoading = false
                }
                
                if !global.hasAskedReview &&
                    refreshCounter > 3 &&
                    global.getUtcTime().timeIntervalSince(global.firstLaunchedAt) > 60 * 60 * 24 * 1 {
                    global.hasAskedReview = true
                    activeAlert = .opening
                }
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
