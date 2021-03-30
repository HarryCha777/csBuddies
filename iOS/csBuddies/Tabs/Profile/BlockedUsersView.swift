//
//  blockedBuddyIdsView.swift
//  csBuddies
//
//  Created by Harry Cha on 6/12/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct blockedBuddyIdsView: View {
    @EnvironmentObject var global: Global
    
    @State private var buddyIds = [String]()
    @State private var mustgetBlockedBuddies = true
    @State private var isLoading = false
    @State private var canLoadMore = false
    @State private var bottomBlockedAt = Date()
    
    var body: some View {
        List {
            ForEach(buddyIds, id: \.self) { buddyId in
                if global.blockedBuddyIds.contains(buddyId) { // Hide unblocked users immediately without refreshing.
                    UserPreviewView(userId: buddyId)
                }
            }
            // Do not use .id(UUID()) to prevent calling PHP on each tab change.

            InfiniteScrollView(emptyText: "You have not blocked anyone.", isLoading: isLoading, isEmpty: buddyIds.count == 0, canLoadMore: canLoadMore, loadMore: getBlockedBuddies)
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Blocked Buddies", displayMode: .inline)
        .refresh(isRefreshing: $mustgetBlockedBuddies, isRefreshingBool: mustgetBlockedBuddies) {
            bottomBlockedAt = global.getUtcTime()
            buddyIds.removeAll()
            getBlockedBuddies()
        }
    }
    
    func getBlockedBuddies() {
        if isLoading {
            return
        }
        isLoading = true
        canLoadMore = true
        
        global.firebaseUser!.getIDToken(completion: { (token, error) in
            let postString =
                "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "bottomBlockedAt=\(bottomBlockedAt.toString())"
            global.runHttp(script: "getBlockedBuddies", postString: postString) { json in
                if json.count <= 1 {
                    mustgetBlockedBuddies = false
                    isLoading = false
                    canLoadMore = false
                    return
                }
                
                for i in 0...json.count - 2 {
                    let row = json[String(i)] as! NSDictionary
                    let userPreviewData = UserPreviewData(
                        userId: row["buddyId"] as! String,
                        username: row["username"] as! String,
                        gender: row["gender"] as! Int,
                        birthday: (row["birthday"] as! String).toDate(hasTime: false),
                        country: row["country"] as! Int,
                        intro: row["intro"] as! String,
                        lastVisitedAt: (row["lastVisitedAt"] as! String).toDate())
                    userPreviewData.updateClientData()
                    buddyIds.append(userPreviewData.userId)
                }
                
                let lastRow = json[String(json.count - 1)] as! NSDictionary
                bottomBlockedAt = (lastRow["bottomBlockedAt"] as! String).toDate()
                
                mustgetBlockedBuddies = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Prevent calling PHP twice on each load.
                    isLoading = false
                }
            }
        })
    }
}
