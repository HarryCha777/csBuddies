//
//  UserView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/22/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct UserView: View {
    @EnvironmentObject var global: Global
    @Environment(\.colorScheme) var colorScheme
    
    let userId: String
    // global.users[userId] is not required to be set in advance.
    let isProfileTab: Bool
    
    @State private var mustGetBuddy = true
    @State private var mustGetBytesAndComments = false
    @State private var isLoading = false
    
    @State private var mustVisitChatRoom = false
    @State private var showActionSheet = false
    
    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            joinToMessage,
            joinToBlock,
            joinToReport,
            block
    }
    
    @State var activeSheet: Sheets?
    enum Sheets: Identifiable {
        var id: Int { self.hashValue }
        case
            profileEdit,
            buddiesProfileReport
    }
    
    init(userId: String, isProfileTab: Bool = false) {
        self.userId = userId
        self.isProfileTab = isProfileTab
    }
    
    var body: some View {
        ZStack {
            List {
                if isLoading || global.users[userId] == nil {
                    LottieView(name: "load", size: 300, mustLoop: true)
                } else if global.users[userId]!.isBanned {
                    SimpleView(
                        lottieView: LottieView(name: "error", size: 200),
                        title: "This user is banned.")
                } else if global.users[userId]!.isDeleted {
                    SimpleView(
                        lottieView: LottieView(name: "noData", size: 300),
                        title: "This user is deleted.")
                } else {
                    UserProfileView(userId: userId, mustGetBytesAndComments: $mustGetBytesAndComments)
                }
            }
            .listStyle(InsetGroupedListStyle())
            
            if !isLoading && global.myId != userId && global.users[userId] != nil && !global.users[userId]!.isBanned && !global.users[userId]!.isDeleted {
                FloatingActionButton(systemName: "text.bubble") {
                    if global.myId == "" {
                        activeAlert = .joinToMessage
                    } else {
                        mustVisitChatRoom = true
                    }
                }
                
                NavigationLinkEmpty(destination: ChatRoomView(buddyId: userId, buddyUsername: global.users[userId]!.username), isActive: $mustVisitChatRoom)
            }
        }
        .navigationBarTitle(isProfileTab ? "Profile" : global.users[userId] == nil ? "" : global.users[userId]!.username, displayMode: isProfileTab ? .large : .inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack { // Having at least 2 views inside HStack is necessary to make Image larger.
                    if !isLoading && global.myId == userId {
                        Button(action: {
                            setEditVars()
                            activeSheet = .profileEdit
                        }) {
                            Image(systemName: "person.crop.circle")
                                .font(.largeTitle)
                        }
                        
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gear")
                                .font(.largeTitle)
                        }
                    } else if !isLoading && global.users[userId] != nil && !global.users[userId]!.isBanned && !global.users[userId]!.isDeleted {
                        // Place Spacer inside the if condition or the button below will slide to the left on each refresh.
                        Spacer()
                        Button(action: {
                            showActionSheet = true
                        }) {
                            Image(systemName: "ellipsis")
                                .font(.largeTitle)
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
            case .profileEdit:
                NavigationView {
                    ProfileEditView(mustUpdateProfile: $mustGetBuddy)
                        .environmentObject(globalObject)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            case .buddiesProfileReport:
                NavigationView {
                    ReportView(buddyId: userId)
                        .environmentObject(globalObject)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .joinToMessage:
                return Alert(title: Text("Join us to message \(global.users[userId]!.username)."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Join"), action: {
                    global.activeRootView = .join
                }))
            case .joinToBlock:
                return Alert(title: Text("Join us to block \(global.users[userId]!.username)."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Join"), action: {
                    global.activeRootView = .join
                }))
            case .joinToReport:
                return Alert(title: Text("Join us to report \(global.users[userId]!.username)."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Join"), action: {
                    global.activeRootView = .join
                }))
            case .block:
                return Alert(title: Text("Block Buddy"), message: Text("Their profiles, bytes, and comments will be hidden, and you will no longer receive messages or notifications from them. They will never know that you blocked them."), primaryButton: .default(Text("Cancel")), secondaryButton: .destructive(Text("Block"), action: {
                    let userPreviewData = UserPreviewData(
                        userId: userId,
                        username: global.users[userId]!.username,
                        birthday: global.users[userId]!.birthday,
                        genderIndex: global.users[userId]!.genderIndex,
                        countryIndex: global.users[userId]!.countryIndex,
                        intro: global.users[userId]!.intro,
                        lastVisitedAt: global.users[userId]!.lastVisitedAt)
                    userPreviewData.updateClientData()
                    global.block(buddyId: userId)
                }))
            }
        }
        .refresh(isRefreshing: $mustGetBuddy, isRefreshingBool: mustGetBuddy) {
            getBuddy()
        }
    }
    
    func getBuddy() {
        if isLoading {
            return
        }
        isLoading = true
        
        if global.myId == userId {
            let userData = UserData(
                userId: global.myId,
                username: global.username,
                genderIndex: global.genderIndex,
                birthday: global.birthday,
                countryIndex: global.countryIndex,
                interests: global.interests,
                intro: global.intro,
                gitHub: global.gitHub,
                linkedIn: global.linkedIn,
                lastVisitedAt: global.getUtcTime(),
                lastUpdatedAt: Date(timeIntervalSince1970: 0),
                isAdmin: global.isAdmin,
                bytesMade: global.bytesMade,
                commentsMade: global.commentsMade,
                byteLikesReceived: global.byteLikesReceived,
                commentLikesReceived: global.commentLikesReceived,
                byteLikesGiven: global.byteLikesGiven,
                commentLikesGiven: global.commentLikesGiven)
            userData.updateClientData()
            
            mustGetBuddy = false
            isLoading = false
            mustGetBytesAndComments = true
            return
        }
        
        let postString =
            "buddyId=\(userId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
        global.runPhp(script: "getBuddy", postString: postString) { json in
            if json["isBanned"] != nil &&
                json["isBanned"] as! Bool {
                var userData = UserData(userId: userId, username: json["username"] as! String, genderIndex: 0, birthday: global.getUtcTime(), countryIndex: 0, interests: [String](), intro: "", gitHub: "", linkedIn: "", lastVisitedAt: global.getUtcTime(), lastUpdatedAt: global.getUtcTime(), isAdmin: false, bytesMade: 0, commentsMade: 0, byteLikesReceived: 0, commentLikesReceived: 0, byteLikesGiven: 0, commentLikesGiven: 0)
                userData.isBanned = true
                userData.updateClientData()
                
                mustGetBuddy = false
                isLoading = false
                return
            }
            
            if json["isDeleted"] != nil &&
                json["isDeleted"] as! Bool {
                var userData = UserData(userId: userId, username: json["username"] as! String, genderIndex: 0, birthday: global.getUtcTime(), countryIndex: 0, interests: [String](), intro: "", gitHub: "", linkedIn: "", lastVisitedAt: global.getUtcTime(), lastUpdatedAt: global.getUtcTime(), isAdmin: false, bytesMade: 0, commentsMade: 0, byteLikesReceived: 0, commentLikesReceived: 0, byteLikesGiven: 0, commentLikesGiven: 0)
                userData.isDeleted = true
                userData.updateClientData()
                
                mustGetBuddy = false
                isLoading = false
                return
            }
            
            let userData = UserData(
                userId: userId,
                username: json["username"] as! String,
                genderIndex: json["gender"] as! Int,
                birthday: (json["birthday"] as! String).toDate(fromFormat: "yyyy-MM-dd"),
                countryIndex: json["country"] as! Int,
                interests: (json["interests"] as! String).toInterestsArray(),
                intro: json["intro"] as! String,
                gitHub: json["gitHub"] as! String,
                linkedIn: json["linkedIn"] as! String,
                lastVisitedAt: (json["lastVisitedAt"] as! String).toDate(),
                lastUpdatedAt: (json["lastUpdatedAt"] as! String).toDate(),
                isAdmin: json["isAdmin"] as! Bool,
                bytesMade: json["bytesMade"] as! Int,
                commentsMade: json["commentsMade"] as! Int,
                byteLikesReceived: json["byteLikesReceived"] as! Int,
                commentLikesReceived: json["commentLikesReceived"] as! Int,
                byteLikesGiven: json["byteLikesGiven"] as! Int,
                commentLikesGiven: json["commentLikesGiven"] as! Int)
            userData.updateClientData()
            
            mustGetBuddy = false
            isLoading = false
            mustGetBytesAndComments = true
        }
    }
    
    // Reset edit variables here instead of onAppear of ProfileEditView since it may be navigated from other views.
    func setEditVars() {
        global.newSmallImage = global.smallImage
        global.newBigImage = global.bigImage
        global.newGenderIndex = global.genderIndex
        global.newBirthday = global.birthday
        global.newCountryIndex = global.countryIndex
        global.newInterests = global.interests
        global.newOtherInterests = global.otherInterests
        global.newIntro = global.intro
        global.newGitHub = global.gitHub
        global.newLinkedIn = global.linkedIn
        
        let userPreviewData = UserPreviewData(
            userId: global.myId,
            username: global.username,
            birthday: global.newBirthday,
            genderIndex: global.newGenderIndex,
            countryIndex: global.newCountryIndex,
            intro: global.newIntro,
            lastVisitedAt: global.getUtcTime())
        userPreviewData.updateClientData()
    }
    
    func getActionSheet() -> ActionSheet {
        var buttons = [Alert.Button]()
        
        if !global.blockedBuddyIds.contains(userId) {
            buttons += [Alert.Button.destructive(Text("Block")) {
                if global.myId == "" {
                    activeAlert = .joinToBlock
                } else {
                    activeAlert = .block
                }
            }]
        } else {
            buttons += [Alert.Button.default(Text("Unblock")) {
                global.unblock(buddyId: userId)
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

struct UserData: Identifiable, Codable {
    var id = UUID()
    var userId: String
    var username: String
    var genderIndex: Int
    var birthday: Date
    var countryIndex: Int
    var interests: [String]
    var intro: String
    var gitHub: String
    var linkedIn: String
    var lastVisitedAt: Date
    var lastUpdatedAt: Date
    var isAdmin: Bool
    var bytesMade: Int
    var commentsMade: Int
    var byteLikesReceived: Int
    var commentLikesReceived: Int
    var byteLikesGiven: Int
    var commentLikesGiven: Int
    var isBanned = false
    var isDeleted = false
    
    init(userId: String,
         username: String,
         genderIndex: Int,
         birthday: Date,
         countryIndex: Int,
         interests: [String],
         intro: String,
         gitHub: String,
         linkedIn: String,
         lastVisitedAt: Date,
         lastUpdatedAt: Date,
         isAdmin: Bool,
         bytesMade: Int,
         commentsMade: Int,
         byteLikesReceived: Int,
         commentLikesReceived: Int,
         byteLikesGiven: Int,
         commentLikesGiven: Int) {
        self.userId = userId
        self.username = username
        self.genderIndex = genderIndex
        self.birthday = birthday
        self.countryIndex = countryIndex
        self.interests = interests
        self.intro = intro
        self.gitHub = gitHub
        self.linkedIn = linkedIn
        self.lastVisitedAt = lastVisitedAt
        self.lastUpdatedAt = lastUpdatedAt
        self.isAdmin = isAdmin
        self.bytesMade = bytesMade
        self.commentsMade = commentsMade
        self.byteLikesReceived = byteLikesReceived
        self.commentLikesReceived = commentLikesReceived
        self.byteLikesGiven = byteLikesGiven
        self.commentLikesGiven = commentLikesGiven
    }
    
    func updateClientData() {
        globalObject.users[userId] = self
        
        if username != "" { // Make sure that the user is not banned or deleted.
            if globalObject.inboxData.notifications.contains(where: { $0.buddyId == userId }) {
                let index = globalObject.inboxData.notifications.firstIndex(where: { $0.buddyId == userId })
                globalObject.inboxData.notifications[index!].buddyUsername = username
            }
            
            if globalObject.chatData.contains(where: { $0.key == userId }) &&
                globalObject.chatData[userId]!.username != username {
                globalObject.chatData[userId]!.username = username
            }
        }
        
        if globalObject.smallImageCache.object(forKey: userId as NSString) != nil &&
            globalObject.smallImageCache.object(forKey: userId as NSString)!.lastCachedAt < lastUpdatedAt {
            globalObject.smallImageCache.removeObject(forKey: userId as NSString)
            globalObject.bigImageCache.removeObject(forKey: userId as NSString)
        }
    }
}
