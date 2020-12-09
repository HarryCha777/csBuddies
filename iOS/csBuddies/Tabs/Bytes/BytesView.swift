//
//  BytesView.swift
//  csBuddies
//
//  Created by Harry Cha on 10/15/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase

struct BytesView: View {
    @EnvironmentObject var global: Global
    
    @State private var mustGetBytes = true
    @State private var bytes = [BytesPostData]()
    @State private var bottomPostTime = Date()
    @State private var bottomTrendingScore = 30000.0
    @State private var bottomLikes = 30000
    @State private var isLoading = false
    @State private var isRefreshing = false
    @State private var canLoadMore = false
    
    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            joinToPost
    }
    
    @State var activeSheet: Sheets?
    enum Sheets: Identifiable {
        var id: Int { self.hashValue }
        case
            bytesWrite,
            bytesFilter
    }

    var body: some View {
        ZStack {
            if mustGetBytes {
                Spacer()
                    .onAppear {
                        mustGetBytes = false
                        bottomPostTime = global.getUtcTime()
                        bottomTrendingScore = 30000.0
                        bottomLikes = 30000
                        bytes.removeAll()
                        getBytes()
                    }
            }
            
            List {
                // Indices will not update the views when more profiles are loaded.
                // Using enumerated or zip will require ad banner to stick to a profile using Vstack.
                // Also, using enumerated or zip will cause a glitch when more profiles are loaded after clicking on a banner ad.
                // AdmobNativeAdsView slows down the app, so stop showing them at some point.
                ForEach(bytes) { bytesPostData in
                    if !global.blocks.contains(where: { $0.userId == bytesPostData.userId }) {
                        BytesPostView(bytesPostData: bytesPostData)
                    }

                    if bytes.firstIndex(where: { $0.id == bytesPostData.id })! % 10 == 9 &&
                        bytes.firstIndex(where: { $0.id == bytesPostData.id })! < 500 &&
                        !global.isPremium {
                        //AdmobNativeAdsBytesView()
                    }
                }
                // Do not use .id(UUID()) to prevent calling PHP on each tab change and bytes from staying still when they are liked.

                HStack {
                    Spacer()
                    if isLoading {
                        LottieView(name: "load", size: 300, padding: -50, mustLoop: true)
                    } else if bytes.count == 0 {
                        LottieView(name: "noData", size: 300, padding: -50)
                    } else {
                        Text("End")
                            .onAppear {
                                if canLoadMore {
                                    getBytes()
                                }
                            }
                    }
                    Spacer()
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .navigationBarTitle("Bytes")
        .pullToRefresh(isShowing: $isRefreshing) {
            bottomPostTime = global.getUtcTime()
            bottomTrendingScore = 30000.0
            bottomLikes = 30000
            bytes.removeAll()
            getBytes()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack { // Having at least 2 views inside HStack is necessary to make Image larger.
                    Button(action: {
                        if global.myId == "" {
                            activeAlert = .joinToPost
                        } else {
                            activeSheet = .bytesWrite
                        }
                    }) {
                        Image(systemName: "square.and.pencil")
                            .font(.largeTitle)
                    }

                    Button(action: {
                        setNewFilterVars()
                        activeSheet = .bytesFilter
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.largeTitle)
                    }
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .bytesWrite:
                NavigationView {
                    BytesWriteView(mustGetBytes: $mustGetBytes)
                        .environmentObject(globalObject)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            case .bytesFilter:
                NavigationView {
                    BytesFilterView(mustGetBytes: $mustGetBytes)
                        .environmentObject(globalObject)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .joinToPost:
                return Alert(title: Text("Join us to write a byte."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Join"), action: {
                    global.activeRootView = .join
                }))
            }
        }
    }
    
    func setNewFilterVars() {
        global.newBytesFilterSortIndex = global.bytesFilterSortIndex
        global.newBytesFilterTimeIndex = global.bytesFilterTimeIndex
    }

    func getBytes() {
        if isLoading {
            return
        }
        isLoading = true
        canLoadMore = true
        
        let postString =
            "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "sort=\(global.bytesFilterSortIndex)&" +
            "time=\(global.bytesFilterTimeIndex)&" +
            "bottomPostTime=\(bottomPostTime.toString())&" +
            "bottomTrendingScore=\(bottomTrendingScore)&" +
            "bottomLikes=\(bottomLikes)"
        global.runPhp(script: "getFilteredBytes", postString: postString) { json in
            if json.count <= 1 {
                isLoading = false
                isRefreshing = false
                canLoadMore = false
                return
            }
            
            for i in 1...json.count - 1 {
                let row = json[String(i)] as! NSDictionary
                let bytesPostData = BytesPostData(
                    byteId: row["byteId"] as! String,
                    userId: row["userId"] as! String,
                    username: row["username"] as! String,
                    isOnline: global.isOnline(lastVisitTimeAny: row["lastVisitTime"]),
                    content: row["content"] as! String,
                    likes: row["likes"] as! Int,
                    isLiked: row["isLiked"] as! Bool,
                    postTime: (row["postTime"] as! String).toDate())
                bytes.append(bytesPostData)
                updateClientData(bytesPostData: bytesPostData)
            }
            
            let lastRow = json[String(json.count)] as! NSDictionary
            bottomPostTime = (lastRow["bottomPostTime"] as! String).toDate()
            bottomTrendingScore = lastRow["bottomTrendingScore"] as! Double
            bottomLikes = lastRow["bottomLikes"] as! Int
            
            isRefreshing = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Prevent calling PHP twice on each load.
                isLoading = false
            }
        }
    }
    
    func updateClientData(bytesPostData: BytesPostData) {
        if global.savedBytes.contains(where: { $0.byteId == bytesPostData.byteId }) {
            let index = global.savedBytes.firstIndex(where: { $0.byteId == bytesPostData.byteId })
            global.savedBytes[index!] = bytesPostData
        }
    }
}
