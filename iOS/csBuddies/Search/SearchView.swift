//
//  SearchView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/18/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase
import SwiftUIRefresh

struct SearchView: View {
    @EnvironmentObject var global: Global
    
    let requestOnOpeningTitle = "Just a moment please!"
    let requestOnOpeningMessage = "Are you getting to know new coders in this app?"
    let requestOnYesTitle = "We are super glad to hear that!   :)"
    let requestOnYesMessage = "Would you mind rating this app on the App Store?"
    let requestOnNoTitle = "We are so sorry to hear that.   :("
    let requestOnNoMessage = "Would you mind providing feedback so we can improve this app for you?"
    
    let requestOnOpeningSayYes = "Yes, I am!"
    let requestOnOpeningSayNo = "Not really."
    let requestAfterOpeningSayYes = "Sure, take me there!"
    let requestAfterOpeningSayNo = "No, don't ask again."
    
    @State private var searchResults = [SearchProfileLinkData]()
    @State private var lastSearchDate = Date()
    @State private var isSearching = false
    @State private var isRefreshing = false
    @State private var canLoadMore = false
    @State private var mustClearSearchResults = false
    @State private var mustVisitSearchFilter = false
    
    @State private var searchCounter = 0
    @State private var showRequestOnOpening = false
    @State private var showRequestOnYes = false
    @State private var showRequestOnNo = false
    
    var body: some View {
        NavigationView {
            HStack {
                // Hide review alert view from screen.
                reviewAlertView()
                    .frame(width: 0)
                
                // Hide search function from screen but execute regardless of list scroll position.
                if self.global.mustSearch {
                    Spacer()
                        .onAppear {
                            self.global.mustSearch = false
                            self.lastSearchDate = self.global.getUtcTime()
                            self.mustClearSearchResults = true
                            self.searchResults.removeAll()
                            self.searchCounter += 1
                            self.search()
                        }
                }
                
                List {
                    if global.announcement.count != 0 {
                        HStack {
                            Text(global.announcement)
                                .font(.system(size: 14))
                                .foregroundColor(Color.white)
                            Spacer()
                            Image(systemName: "xmark")
                                .foregroundColor(Color.white)
                                .onTapGesture {
                                    global.announcement = ""
                                }
                        }
                        .listRowBackground(Color.orange)
                    }

                    // Indices will not update the views when more profiles are loaded.
                    // Using enumerated or zip will require ad banner to stick to a profile using Vstack.
                    // Also, using enumerated or zip will cause a glitch when more profiles are loaded after clicking on a banner ad.
                    // Admob Native Ads View slows down the app, so stop showing them at some point.
                    ForEach(searchResults) { searchProfileLinkData in
                        SearchProfileLinkView(searchProfileLinkData: searchProfileLinkData)
                        if self.searchResults.firstIndex(where: { $0.id == searchProfileLinkData.id })! % 10 == 9 &&
                            self.searchResults.firstIndex(where: { $0.id == searchProfileLinkData.id })! < 500 &&
                            !self.global.isPremium {
                            AdmobNativeAdsView()
                        }
                    }
                    
                    if canLoadMore {
                        Text("Loading...")
                            .onAppear {
                                if self.canLoadMore { // check condition again since view updates are slow
                                    self.search()
                                }
                        }
                    } else if searchResults.count == 0 {
                        Text("No Result")
                    } else {
                        Text("End of List")
                    }
                }
                .alert(isPresented: $global.showWelcomeAlert) {
                    Alert(title: Text("Welcome!"), message: Text("We're glad to have you with us.\nPlease feel free to search for coding friends here!"), dismissButton: .default(Text("OK")))
                }
                // Using UUID updates search results much faster, but scrolls up to top. So use it when refreshing or filtering but not when scrolling down.
                .if(mustClearSearchResults) { content in
                    content.id(UUID())
                }
                .roundCorners()
                .navigationBarTitle("Search")
                .navigationBarItems(trailing:
                    ZStack {
                        Button(action: {
                            self.setNewFilterVars()
                            self.mustVisitSearchFilter = true
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .imageScale(.large)
                        }
                        
                        NavigationLink(destination: SearchFilterView(), isActive: self.$mustVisitSearchFilter) {
                            EmptyView()
                        }
                    }
                )
                .pullToRefresh(isShowing: $isRefreshing) {
                    self.lastSearchDate = self.global.getUtcTime()
                    self.mustClearSearchResults = true
                    self.searchResults.removeAll()
                    self.searchCounter += 1
                    self.search()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            if !Calendar.current.isDate(self.global.getUtcTime(), inSameDayAs: self.global.lastVisit) {
                self.global.lastVisit = self.global.getUtcTime()
                let postString =
                    "username=\(self.global.username.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                    "password=\(self.global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
                self.global.runPhp(script: "updateLastVisit", postString: postString) { json in }
            }
        }
    }
    
    // Reset new filter variables here instead of on appear of Search Filter View since it may be navigated from other views.
    func setNewFilterVars() {
        global.newFilterGenderIndex = global.filterGenderIndex
        global.newFilterMinAge = global.filterMinAge
        global.newFilterMaxAge = global.filterMaxAge
        global.newFilterAgeRange = toDouble(age: global.newFilterMinAge)...toDouble(age: global.newFilterMaxAge)
        global.newFilterCountryIndex = global.filterCountryIndex
        global.newFilterInterests = global.filterInterests
        global.newFilterLevelIndex = global.filterLevelIndex
        global.newFilterHasImage = global.filterHasImage
        global.newFilterHasGitHub = global.filterHasGitHub
        global.newFilterHasLinkedIn = global.filterHasLinkedIn
        global.newFilterSortIndex = global.filterSortIndex
    }

    func search() {
        if isSearching {
            return
        }
        isSearching = true
        canLoadMore = true
        
        let postString =
            "username=\(global.username.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "password=\(global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "gender=\(global.filterGenderIndex - 1)&" +
            "minAge=\(global.filterMinAge)&" +
            "maxAge=\(global.filterMaxAge)&" +
            "country=\(global.filterCountryIndex - 1)&" +
            "hasImage=\(global.filterHasImage)&" +
            "hasGitHub=\(global.filterHasGitHub)&" +
            "hasLinkedIn=\(global.filterHasLinkedIn)&" +
            "interests=\(global.filterInterests.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "level=\(global.filterLevelIndex - 1)&" +
            "sort=\(global.filterSortIndex)&" +
            "lastSearchDate=\(lastSearchDate.toString(toFormat: "yyyy-MM-dd HH:mm:ss"))"
        global.runPhp(script: "getSearchResults", postString: postString) { json in
            if json.count <= 1 {
                self.isSearching = false
                self.isRefreshing = false
                self.canLoadMore = false
                return
            }
            
            for i in 1...json.count - 1 {
                let row = json[String(i)] as! NSDictionary
                let searchProfileLinkData = SearchProfileLinkData(
                    id: row["username"] as! String,
                    image: row["image"] as! String,
                    username: row["username"] as! String,
                    birthday: (row["birthday"] as! String).toDate(fromFormat: "yyyy-MM-dd", hasTime: false),
                    genderIndex: row["gender"] as! Int,
                    shortInterests: row["shortInterests"] as! String,
                    shortIntro: row["shortIntro"] as! String,
                    hasGitHub: row["hasGitHub"] as! Bool,
                    hasLinkedIn: row["hasLinkedIn"] as! Bool)
                self.searchResults.append(searchProfileLinkData)
            }
            
            let lastRow = json[String(json.count)] as! NSDictionary
            self.lastSearchDate = (lastRow["lastSearchDate"] as! String).toDate(fromFormat: "yyyy-MM-dd HH:mm:ss")
            
            self.isSearching = false
            self.isRefreshing = false
            self.mustClearSearchResults = false
            
            if !self.global.requestedReview &&
                self.searchCounter > 3 &&
                self.global.getUtcTime().timeIntervalSince(self.global.firstLaunchDate) > 60 * 60 * 24 * 1 {
                self.global.requestedReview = true
                self.showRequestOnOpening = true
            }
        }
    }
    
    func toDouble(age: Int) -> Double {
        return Double(age - 13) / Double(80 - 13)
    }
    
    func reviewAlertView() -> some View {
        HStack {
            Spacer()
                .alert(isPresented: $showRequestOnOpening) {
                    Alert(title: Text(requestOnOpeningTitle), message: Text(requestOnOpeningMessage), primaryButton: .destructive(Text(requestOnOpeningSayNo), action: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // very short delay is needed
                            self.showRequestOnNo = true
                        }
                    }), secondaryButton: .default(Text(requestOnOpeningSayYes), action: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // very short delay is needed
                            self.showRequestOnYes = true
                        }
                    }))
            }
            
            Spacer()
                .alert(isPresented: $showRequestOnYes) {
                    Alert(title: Text(requestOnYesTitle), message: Text(requestOnYesMessage), primaryButton: .default(Text(requestAfterOpeningSayYes), action: {
                        self.global.linkToReview()
                    }), secondaryButton: .destructive(Text(requestAfterOpeningSayNo)))
            }
            
            Spacer()
                .alert(isPresented: $showRequestOnNo) {
                    Alert(title: Text(requestOnNoTitle), message: Text(requestOnNoMessage), primaryButton: .default(Text(requestAfterOpeningSayYes), action: {
                        self.global.linkToReview()
                    }), secondaryButton: .destructive(Text(requestAfterOpeningSayNo)))
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(Global())
    }
}
