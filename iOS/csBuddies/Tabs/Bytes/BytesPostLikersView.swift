//
//  BytesPostLikersView.swift
//  csBuddies
//
//  Created by Harry Cha on 10/15/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct BytesPostLikersView: View {
    @EnvironmentObject var global: Global
    
    let byteId: String
    
    @State private var hasRunOnAppear = false
    
    @State private var likers = [UserRowData]()
    @State private var bottomLikeTime = Date()
    @State private var isLoading = false
    @State private var isRefreshing = false
    @State private var canLoadMore = false

    var body: some View {
        List {
            ForEach(likers) { userRowData in
                NavigationLinkBorderless(destination:
                                            VStack {
                                                if global.myId == userRowData.userId {
                                                    ProfileView()
                                                } else {
                                                    BuddiesProfileView(buddyId: userRowData.userId)
                                                }
                                            }) {
                    UserRowView(userRowData: userRowData)
                }
            }
            // Do not use .id(UUID()) to prevent calling PHP on each tab change.

            HStack {
                Spacer()
                if isLoading {
                    LottieView(name: "load", size: 300, padding: -50, mustLoop: true)
                } else if likers.count == 0 {
                    LottieView(name: "noData", size: 300, padding: -50)
                } else {
                    Text("End")
                        .onAppear {
                            if canLoadMore {
                                getLikers()
                            }
                        }
                }
                Spacer()
            }
        }
        .navigationBarTitle("Liked By", displayMode: .inline)
        .pullToRefresh(isShowing: $isRefreshing) {
            bottomLikeTime = global.getUtcTime()
            likers.removeAll()
            getLikers()
        }
        .onAppear {
            if !hasRunOnAppear { // Prevent calling PHP on each tab change.
                hasRunOnAppear = true
                bottomLikeTime = global.getUtcTime()
                getLikers()
            }
        }
    }
    
    func getLikers() {
        if isLoading {
            return
        }
        isLoading = true
        canLoadMore = true
        
        let postString =
            "byteId=\(byteId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "bottomLikeTime=\(bottomLikeTime.toString())"
        global.runPhp(script: "getLikers", postString: postString) { json in
            if json.count <= 1 {
                isLoading = false
                isRefreshing = false
                canLoadMore = false
                return
            }
            
            for i in 1...json.count - 1 {
                let row = json[String(i)] as! NSDictionary
                let userRowData = UserRowData(
                    userId: row["userId"] as! String,
                    username: row["username"] as! String,
                    isOnline: global.isOnline(lastVisitTimeAny: row["lastVisitTime"]),
                    appendTime: (row["likeTime"] as! String).toDate())
                likers.append(userRowData)
            }
            
            let lastRow = json[String(json.count)] as! NSDictionary
            bottomLikeTime = (lastRow["bottomLikeTime"] as! String).toDate()
            
            isRefreshing = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Prevent calling PHP twice on each load.
                isLoading = false
            }
        }
    }
}
