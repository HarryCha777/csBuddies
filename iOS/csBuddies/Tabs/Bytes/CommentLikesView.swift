//
//  CommentLikesView.swift
//  csBuddies
//
//  Created by Harry Cha on 1/18/21.
//  Copyright © 2021 Harry Cha. All rights reserved.
//

import SwiftUI

struct CommentLikesView: View {
    @EnvironmentObject var global: Global
    
    let commentId: String
    // global.comments[commentId] must be set in advance.
    
    @State private var likerIds = [String]()
    @State private var mustGetLikes = true
    @State private var isLoading = false
    @State private var canLoadMore = false
    @State private var bottomLastUpdatedAt = Date()
    
    var body: some View {
        List {
            ForEach(likerIds, id: \.self) { userId in
                if !global.blockedBuddyIds.contains(userId) {
                    UserPreviewView(userId: userId)
                }
            }
            // Do not use .id(UUID()) to prevent calling PHP on each tab change.

            InfiniteScrollView(emptyText: "No likes yet", isLoading: isLoading, isEmpty: likerIds.count == 0, canLoadMore: canLoadMore, loadMore: getCommentLikes)
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Liked By", displayMode: .inline)
        .refresh(isRefreshing: $mustGetLikes, isRefreshingBool: mustGetLikes) {
            bottomLastUpdatedAt = global.getUtcTime()
            likerIds.removeAll()
            getCommentLikes()
        }
    }
    
    func getCommentLikes() {
        if isLoading {
            return
        }
        isLoading = true
        canLoadMore = true
        
        global.getTokenIfSignedIn { token in
            let postString =
                "token=\(token.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "commentId=\(commentId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "bottomLastUpdatedAt=\(bottomLastUpdatedAt.toString())"
            global.runHttp(script: "getCommentLikes", postString: postString) { json in
                if json.count <= 1 {
                    mustGetLikes = false
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
                    likerIds.append(userPreviewData.userId)
                }
                
                let lastRow = json[String(json.count - 1)] as! NSDictionary
                bottomLastUpdatedAt = (lastRow["bottomLastUpdatedAt"] as! String).toDate()
                
                mustGetLikes = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Prevent calling PHP twice on each load.
                    isLoading = false
                }
            }
        }
    }
}
