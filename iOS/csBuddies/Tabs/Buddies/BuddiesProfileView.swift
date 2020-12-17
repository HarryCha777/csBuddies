//
//  BuddiesProfileView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/22/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct BuddiesProfileView: View {
    @EnvironmentObject var global: Global
    @Environment(\.colorScheme) var colorScheme
    
    let buddyId: String
    
    @State private var hasRunOnAppear = false
    @State private var userProfileData = UserProfileData(userId: "", username: "", genderIndex: 0, birthday: Date(), countryIndex: 0, interests: [String](), intro: "", gitHub: "", linkedIn: "", isOnline: false, lastVisitTime: Date(), bytesMade: 0, likesReceived: 0, likesGiven: 0)
    @State private var isLoading = true
    @State private var isBanned = false
    @State private var isDeleted = false
    @State private var isRefreshing = false
    
    @State private var showActionSheet = false

    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            joinToMessage,
            joinToSave,
            joinToBlock,
            joinToReport,
            block
    }
    
    @State var activeSheet: Sheets?
    enum Sheets: Identifiable {
        var id: Int { self.hashValue }
        case
            buddiesProfileReport
    }

    var body: some View {
        VStack {
            if isLoading {
                LottieView(name: "load", size: 300, mustLoop: true)
                    .onAppear {
                        if !hasRunOnAppear { // Prevent calling PHP on each tab change.
                            hasRunOnAppear = true
                            fetchUser()
                        }
                    }
            } else if isBanned {
                SimpleView(
                    lottieView: LottieView(name: "error", size: 200),
                    title: "This user is banned.")
            } else if isDeleted {
                SimpleView(
                    lottieView: LottieView(name: "noData", size: 300),
                    title: "This user is deleted.")
            } else {
                BuddiesProfileContentView(userProfileData: userProfileData, isRefreshing: isRefreshing)
                    .navigationBarTitle(userProfileData.username, displayMode: .inline)
                    .pullToRefresh(isShowing: $isRefreshing) {
                        fetchUser()
                    }
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            HStack { // Having at least 2 views inside HStack is necessary to make Image larger.
                                if global.myId == "" {
                                    Button(action: {
                                        activeAlert = .joinToMessage
                                    }) {
                                        Image(systemName: "text.bubble")
                                            .font(.largeTitle)
                                    }
                                } else {
                                    NavigationLink(destination: ChatRoomView(buddyId: userProfileData.userId /*buddyId*/, buddyUsername: userProfileData.username)) {
                                        Image(systemName: "text.bubble")
                                            .font(.largeTitle)
                                    }
                                }
                                
                                Button(action: {
                                    showActionSheet = true
                                }) {
                                    Image(systemName: "ellipsis.circle")
                                        .font(.largeTitle)
                                }
                            }
                        }
                    }
            }
        }
        .actionSheet(isPresented: $showActionSheet) {
            getActionSheet()
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .buddiesProfileReport:
                NavigationView {
                    BuddiesProfileReportView(buddyId: buddyId)
                        .environmentObject(globalObject)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .joinToMessage:
                return Alert(title: Text("Join us to message \(userProfileData.username)."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Join"), action: {
                    global.activeRootView = .join
                }))
            case .joinToSave:
                return Alert(title: Text("Join us to save \(userProfileData.username)."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Join"), action: {
                    global.activeRootView = .join
                }))
            case .joinToBlock:
                return Alert(title: Text("Join us to block \(userProfileData.username)."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Join"), action: {
                    global.activeRootView = .join
                }))
            case .joinToReport:
                return Alert(title: Text("Join us to report \(userProfileData.username)."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Join"), action: {
                    global.activeRootView = .join
                }))
            case .block:
                return Alert(title: Text("Block Buddy"), message: Text("You will no longer receive messages or notifications from them. Their activity will also be hidden from your Buddies and Bytes tabs. They will never know that you blocked them."), primaryButton: .default(Text("Cancel")), secondaryButton: .destructive(Text("Block"), action: {
                    global.block(buddyId: buddyId, buddyUsername: userProfileData.username)
                }))
            }
        }
    }
    
    func fetchUser() {
        let postString =
            "buddyId=\(buddyId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
        global.runPhp(script: "getBuddy", postString: postString) { json in
            isBanned = json["isBanned"] as! Bool
            if isBanned {
                isLoading = false
                return
            }
            
            isDeleted = json["isDeleted"] as! Bool
            if isDeleted {
                isLoading = false
                return
            }
            
            userProfileData = UserProfileData(
                userId: buddyId,
                username: json["username"] as! String,
                genderIndex: json["gender"] as! Int,
                birthday: (json["birthday"] as! String).toDate(fromFormat: "yyyy-MM-dd"),
                countryIndex: json["country"] as! Int,
                interests: (json["interests"] as! String).toInterestsArray(),
                intro: json["intro"] as! String,
                gitHub: json["gitHub"] as! String,
                linkedIn: json["linkedIn"] as! String,
                isOnline: global.isOnline(lastVisitTimeAny: json["lastVisitTime"]),
                lastVisitTime: (json["lastVisitTime"] as! String).toDate(),
                bytesMade: json["bytesMade"] as! Int,
                likesReceived: json["likesReceived"] as! Int,
                likesGiven: json["likesGiven"] as! Int)
            let lastUpdateTime = (json["lastUpdateTime"] as! String).toDate()
            updateClientData(username: userProfileData.username, lastUpdateTime: lastUpdateTime)
            
            isRefreshing = false
            isLoading = false
        }
    }
    
    func updateClientData(username: String, lastUpdateTime: Date) {
        if global.chatData.contains(where: { $0.key == buddyId }) &&
            global.chatData[buddyId]!.username != username {
            global.chatData[buddyId]!.username = username
        }
        
        if global.savedUsers.contains(where: { $0.userId == buddyId }) {
            let index = global.savedUsers.firstIndex(where: { $0.userId == buddyId })
            if global.savedUsers[index!].username != username {
                global.savedUsers[index!].username = username
            }
        }
        
        if global.savedBytes.contains(where: { $0.userId == buddyId }) {
            let index = global.savedBytes.firstIndex(where: { $0.userId == buddyId })
            if global.savedBytes[index!].username != username {
                global.savedBytes[index!].username = username
            }
        }
        
        if global.blocks.contains(where: { $0.userId == buddyId }) {
            let index = global.blocks.firstIndex(where: { $0.userId == buddyId })
            if global.blocks[index!].username != username {
                global.blocks[index!].username = username
            }
        }
        
        if global.smallImageCaches.object(forKey: buddyId as NSString) != nil &&
            global.smallImageCaches.object(forKey: buddyId as NSString)!.lastCacheTime < lastUpdateTime {
            global.smallImageCaches.removeObject(forKey: buddyId as NSString)
            global.bigImageCaches.removeObject(forKey: buddyId as NSString)
        }
    }
    
    func getActionSheet() -> ActionSheet {
        var buttons = [Alert.Button]()
        
        if !global.savedUsers.contains(where: { $0.userId == buddyId }) {
            buttons += [Alert.Button.default(Text("Save")) {
                if global.myId == "" {
                    activeAlert = .joinToSave
                } else {
                    global.saveUser(buddyId: buddyId, buddyUsername: userProfileData.username)
                }
            }]
        } else {
            buttons += [Alert.Button.destructive(Text("Forget")) {
                global.forgetUser(buddyId: buddyId)
            }]
        }
        
        if !global.blocks.contains(where: { $0.userId == buddyId }) {
            buttons += [Alert.Button.destructive(Text("Block")) {
                if global.myId == "" {
                    activeAlert = .joinToBlock
                } else {
                    activeAlert = .block
                }
            }]
        } else {
            buttons += [Alert.Button.default(Text("Unblock")) {
                global.unblock(buddyId: buddyId)
            }]
        }
        
        buttons += [Alert.Button.destructive(Text("Report")) {
            if global.myId == "" {
                activeAlert = .joinToReport
            } else {
                activeSheet = .buddiesProfileReport
            }
        }]
        
        return ActionSheet(title: Text("Select an option"),
                           buttons: buttons + [Alert.Button.cancel()])
    }
}
