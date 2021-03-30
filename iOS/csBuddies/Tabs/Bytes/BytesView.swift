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
    
    @State private var byteIds = [String]()
    @State private var mustGetBytes = true
    @State private var isLoading = false
    @State private var canLoadMore = false
    @State private var bottomPostedAt = Date()
    @State private var bottomHotScore = 30000.0
    
    @State private var newByteId = ""
    
    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            joinForInbox,
            joinToWrite
    }
    
    @State var activeSheet: Sheets?
    enum Sheets: Identifiable {
        var id: Int { self.hashValue }
        case
            bytesFilter,
            bytesWrite
    }

    var body: some View {
        ZStack {
            List {
                ForEach(byteIds, id: \.self) { byteId in
                    if !global.blockedBuddyIds.contains(global.bytes[byteId]!.userId) {
                        BytePreviewView(byteId: byteId)
                    }
                }
                // Do not use .id(UUID()) to prevent calling PHP on each tab change and bytes from staying still when they are liked.
                
                InfiniteScrollView(isLoading: isLoading, isEmpty: byteIds.count == 0, canLoadMore: canLoadMore, loadMore: getBytes)
            }
            
            FloatingActionButton(systemName: "pencil") {
                if global.myId == "" {
                    activeAlert = .joinToWrite
                } else {
                    activeSheet = .bytesWrite
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Bytes")
        .refresh(isRefreshing: $mustGetBytes, isRefreshingBool: mustGetBytes) {
            bottomPostedAt = global.getUtcTime()
            bottomHotScore = 30000.0
            byteIds.removeAll()
            getBytes()
        }
        .overlay(
            VStack {
                if newByteId != "" {
                    Spacer()
                        .onAppear {
                            byteIds.insert(newByteId, at: 0)
                            newByteId = ""
                        }
                }
            }
        )
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack { // Having at least 2 views inside HStack is necessary to make Image larger.
                    if global.myId == "" {
                        Button(action: {
                            activeAlert = .joinForInbox
                        }) {
                            Image(systemName: "bell")
                                .font(.largeTitle)
                        }
                    } else {
                        NavigationLink(destination: InboxView()) {
                            ZStack {
                                Image(systemName: "bell")
                                    .font(.largeTitle)
                                
                                if global.getUnreadNotificationsCounter() > 0 {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            ZStack {
                                                Circle()
                                                    .foregroundColor(.red)
                                                
                                                if global.getUnreadNotificationsCounter() <= 99 {
                                                    Text("\(global.getUnreadNotificationsCounter())")
                                                        .foregroundColor(.white)
                                                        .font(Font.system(size: 10))
                                                } else {
                                                    Text("99+")
                                                        .foregroundColor(.white)
                                                        .font(Font.system(size: 10))
                                                }
                                            }
                                            .frame(width: 20, height: 20)
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }

                    Button(action: {
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
                    ByteWriteView(byte: global.byteDraft, newByteId: $newByteId)
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
            case .joinForInbox:
                return Alert(title: Text("Join us to have your inbox."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Join"), action: {
                    global.activeRootView = .join
                }))
            case .joinToWrite:
                return Alert(title: Text("Join us to write a byte."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Join"), action: {
                    global.activeRootView = .join
                }))
            }
        }
    }

    func getBytes() {
        if isLoading {
            return
        }
        isLoading = true
        canLoadMore = true
        
        global.getTokenIfSignedIn { token in
            let postString =
                "token=\(token.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "sort=\(global.bytesFilterSort)&" +
                "bottomPostedAt=\(bottomPostedAt.toString())&" +
                "bottomHotScore=\(bottomHotScore)"
            global.runHttp(script: "getTabBytes", postString: postString) { json in
                if json.count <= 1 {
                    mustGetBytes = false
                    isLoading = false
                    canLoadMore = false
                    return
                }
                
                for i in 0...json.count - 2 {
                    let row = json[String(i)] as! NSDictionary
                    let byteData = ByteData(
                        byteId: row["byteId"] as! String,
                        userId: row["userId"] as! String,
                        username: row["username"] as! String,
                        lastVisitedAt: (row["lastVisitedAt"] as! String).toDate(),
                        content: row["content"] as! String,
                        likes: row["likes"] as! Int,
                        comments: row["comments"] as! Int,
                        isLiked: row["isLiked"] as! Bool,
                        postedAt: (row["postedAt"] as! String).toDate())
                    byteData.updateClientData()
                    byteIds.append(byteData.byteId)
                }
                
                let lastRow = json[String(json.count - 1)] as! NSDictionary
                bottomPostedAt = (lastRow["bottomPostedAt"] as! String).toDate()
                bottomHotScore = lastRow["bottomHotScore"] as! Double
                
                mustGetBytes = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Prevent calling PHP twice on each load.
                    isLoading = false
                }
            }
        }
    }
}
