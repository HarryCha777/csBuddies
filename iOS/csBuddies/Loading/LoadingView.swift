//
//  LoadingView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/15/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase
import TrueTime

struct LoadingView: View {
    @EnvironmentObject var global: Global
    @FetchRequest(entity: User.entity(), sortDescriptors: []) var coreDataUsers: FetchedResults<User>
    
    @State private var showLoadingIndicator = false
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 150)
            Image("transparentSmallLogo")
                .resizable()
                .frame(width: 200, height: 200)
            LottieView(name: "load", size: 300, mustLoop: true)
                .opacity(showLoadingIndicator ? 1 : 0)
                .animation(.easeInOut(duration: 2))
        }
        .padding()
        .onAppear {
            //global.hasUserDataLoaded = false // Make sure user data does not get changed while loading on sign in.
            if !Reachability.isConnectedToNetwork() {
                global.isOffline = true
                return
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showLoadingIndicator = true
            }
            
            listenToGlobalDocument {
                if global.activeRootView == .loading {
                    getReferenceTime() { referenceTime in
                        global.referenceTime = referenceTime
                        
                        if !global.hasUserDataLoaded {
                            loadUserData()
                            global.hasUserDataLoaded = true
                        }
                        
                        global.firebaseUser = Auth.auth().currentUser
                        getMyId() { myId in
                            global.myId = myId
                            
                            if global.myId == "" {
                                global.activeRootView = .tabs
                            } else {
                                global.smallImageCache.setObject(ImageCache(image: global.smallImage, lastCachedAt: global.getUtcTime()), forKey: global.myId as NSString)
                                global.bigImageCache.setObject(ImageCache(image: global.bigImage, lastCachedAt: global.getUtcTime()), forKey: global.myId as NSString)
                                
                                signIn() {
                                    listenToAccounts() {
                                        if global.username == "" { // The app does not have user's core data or isUserOutdated cleared global.username. Use global.username instead of global.myId since global.myId is needed to listen to Firebase accounts and as a parameter to getUser().
                                            getUser() {
                                                global.activeRootView = .welcome
                                            }
                                        } else {
                                            global.activeRootView = .tabs
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func listenToGlobalDocument(completion: @escaping () -> Void) {
        if global.isGlobalListenerSetUp {
            completion() // Prevent getting stuck when LoadingView is loaded the second time whether signed in or not.
            return
        }
        
        global.isGlobalListenerSetUp = true
        
        global.db.collection("global")
            .document("18")
            .addSnapshotListener { documentSnapshot, error in
                global.webServerLink = documentSnapshot!.get("webServerLink") as! String
                global.announcementText = documentSnapshot!.get("announcementText") as! String
                global.announcementLink = documentSnapshot!.get("announcementLink") as! String
                global.maintenanceText = documentSnapshot!.get("maintenanceText") as! String
                global.updateText = documentSnapshot!.get("updateText") as! String
                let isUnderMaintenance = documentSnapshot!.get("isUnderMaintenance") as! Bool
                
                let currentBuild = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as! String)
                let minimumBuild = documentSnapshot!.get("minimumBuild") as! Int
                let mustUpdate = currentBuild! < minimumBuild
                
                if isUnderMaintenance { // MaintenanceView takes precedence.
                    global.activeRootView = .maintenance
                } else if mustUpdate {
                    global.activeRootView = .update
                } else if global.activeRootView == .maintenance ||
                            global.activeRootView == .update {
                    global.activeRootView = .loading
                }
                
                completion() // Wait until the first read before proceeding.
            }
    }
    
    func getReferenceTime(completion: @escaping (ReferenceTime) -> Void) {
        let client = TrueTimeClient.sharedInstance
        client.pause() // Prepare client to start again when this view is reloaded.
        client.start()
        
        client.fetchIfNeeded(completion: { result in
            switch result {
            case let .success(referenceTime):
                completion(referenceTime)
            case .failure(_):
                break
            }
        })
    }
    
    func loadUserData() {
        if coreDataUsers.count == 0 {
            return
        }
        
        let coreDataUser = coreDataUsers[0]
        
        global.username = coreDataUser.username ?? ""
        global.smallImage = coreDataUser.smallImage ?? ""
        global.bigImage = coreDataUser.bigImage ?? ""
        global.genderIndex = Int(coreDataUser.genderIndex)
        global.birthday = coreDataUser.birthday ?? Date(timeIntervalSince1970: 946684800) // Default birthday is 1/1/2000 12:00:00 AM UTC.
        global.countryIndex = Int(coreDataUser.countryIndex)
        global.interests = coreDataUser.interests as? [String] ?? [String]()
        global.otherInterests = coreDataUser.otherInterests ?? ""
        global.intro = coreDataUser.intro ?? ""
        global.github = coreDataUser.github ?? ""
        global.linkedin = coreDataUser.linkedin ?? ""
        
        global.notifyLikes = coreDataUser.notifyLikes
        global.notifyComments = coreDataUser.notifyComments
        global.notifyMessages = coreDataUser.notifyMessages
        global.bytesMade = Int(coreDataUser.bytesMade)
        global.commentsMade = Int(coreDataUser.commentsMade)
        global.byteLikesGiven = Int(coreDataUser.byteLikesGiven)
        global.commentLikesGiven = Int(coreDataUser.commentLikesGiven)
        global.blockedBuddyIds = coreDataUser.blockedBuddyIds as? [String] ?? [String]()
        do {
            global.inboxData = try JSONDecoder().decode(InboxData.self, from: coreDataUser.inboxBinaryData ?? Data())
            global.chatData = try JSONDecoder().decode([String: ChatRoomData].self, from: coreDataUser.chatBinaryData ?? Data())
            for buddyId in global.chatData.keys {
                for index in global.chatData[buddyId]!.messages.indices {
                    global.chatData[buddyId]!.messages[index].isSending = false
                }
            }
        } catch {}

        global.byteDraft = coreDataUser.byteDraft ?? ""
        global.commentDraft = coreDataUser.commentDraft ?? ""
        global.messageDrafts = coreDataUser.messageDrafts as? [String: String] ?? [String: String]()
        
        global.buddiesFilterGenderIndex = Int(coreDataUser.buddiesFilterGenderIndex)
        global.buddiesFilterMinAge = Int(coreDataUser.buddiesFilterMinAge)
        global.buddiesFilterMaxAge = Int(coreDataUser.buddiesFilterMaxAge)
        if global.buddiesFilterMinAge < 13 || global.buddiesFilterMinAge > 130 ||
            global.buddiesFilterMaxAge < 13 || global.buddiesFilterMaxAge > 130 ||
            global.buddiesFilterMinAge > global.buddiesFilterMaxAge {
            global.buddiesFilterMinAge = 13
            global.buddiesFilterMaxAge = 130
        }
        global.buddiesFilterCountryIndex = Int(coreDataUser.buddiesFilterCountryIndex)
        global.buddiesFilterInterests = coreDataUser.buddiesFilterInterests as? [String] ?? [String]()
        global.buddiesFilterSortIndex = Int(coreDataUser.buddiesFilterSortIndex)
        global.bytesFilterSortIndex = Int(coreDataUser.bytesFilterSortIndex)
        global.firstLaunchedAt = coreDataUser.firstLaunchedAt ?? global.getUtcTime()
        global.hasAskedReview = coreDataUser.hasAskedReview
        global.hasAskedNotification = coreDataUser.hasAskedNotification
    }
    
    func getMyId(completion: @escaping (String) -> Void) {
        if global.firebaseUser == nil {
            completion("")
            return
        }
        
        global.firebaseUser!.getIDTokenResult(completion: { (result, error) in
            if //result!.claims["userId"] == nil ||
                result!.claims["userId"] as? String == nil { // User verified email but didn't make a profile.
                completion("")
                return
            }
            
            completion(result!.claims["userId"] as! String)
        })
    }
    
    func signIn(completion: @escaping () -> Void) {
        if !global.hasSignedIn {
            completion()
            return
        }
        
        global.firebaseUser!.getIDToken(completion: { (token, error) in
            let postString =
                "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "fcm=\(Messaging.messaging().fcmToken!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
            global.runPhp(script: "signIn", postString: postString) { json in
                global.hasSignedIn = false
                completion()
            }
        })
    }
    
    func listenToAccounts(completion: @escaping () -> Void) {
        if global.isAccountsListenerSetUp {
            completion() // Prevent getting stuck when LoadingView is loaded the second time while signed in.
            return
        }
        
        global.isAccountsListenerSetUp = true

        global.accountsListener = global.db.collection("accounts")
            .document(global.myId)
            .addSnapshotListener { documentSnapshot, error in
                let hasChanged = documentSnapshot!.get("hasChanged") as! Bool
                if hasChanged ||
                    global.activeRootView == .loading { // Run on app launch.
                    global.firebaseUser!.getIDToken(completion: { (token, error) in
                        let postString =
                            "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                            "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
                        global.runPhp(script: "syncUser", postString: postString) { json in
                            global.isPremium = json["isPremium"] as! Bool
                            global.isAdmin = json["isAdmin"] as! Bool
                            global.byteLikesReceived = json["byteLikesReceived"] as! Int
                            global.commentLikesReceived = json["commentLikesReceived"] as! Int
                            
                            if json["isUserOutdated"] as! Bool {
                                global.username = ""
                                // There is no need to navigate to LoadingView since that will only call getUser() more times than uncessary.
                            }
                            
                            getInboxNotifications(json: json)
                            getMessages(json: json)
                            getReadReceipts(json: json)
                            
                            global.db.collection("accounts")
                                .document(global.myId)
                                .setData(["hasChanged": false], merge: true) { error in }
                            
                            completion() // Wait until the first read before proceeding.
                        }
                    })
                }
            }
    }
    
    func getInboxNotifications(json: NSDictionary) {
        // If the json is empty, it will be NSArray. Otherwise, it will be NSDictionary. So there's no need to make sure its count is > 0.
        var newInboxNotifications = [NotificationData]()
        
        if let byteLikes = json["byteLikes"] as? NSDictionary {
            for i in 1...byteLikes.count {
                let row = byteLikes[String(i)] as! NSDictionary
                let notificationData = NotificationData(
                    notificationId: row["notificationId"] as! String,
                    byteId: row["byteId"] as! String,
                    buddyId: row["buddyId"] as! String,
                    buddyUsername: row["buddyUsername"] as! String,
                    lastVisitedAt: (row["lastVisitedAt"] as! String).toDate(),
                    content: row["content"] as! String,
                    type: 0,
                    notifiedAt: (row["notifiedAt"] as! String).toDate())
                if !global.inboxData.notifications.contains(where: { $0.notificationId == notificationData.notificationId }) &&
                    !newInboxNotifications.contains(where: { $0.notificationId == notificationData.notificationId }) {
                    newInboxNotifications.append(notificationData)
                }
            }
        }
        
        if let byteLikes = json["commentLikes"] as? NSDictionary {
            for i in 1...byteLikes.count {
                let row = byteLikes[String(i)] as! NSDictionary
                let notificationData = NotificationData(
                    notificationId: row["notificationId"] as! String,
                    byteId: row["byteId"] as! String,
                    buddyId: row["buddyId"] as! String,
                    buddyUsername: row["buddyUsername"] as! String,
                    lastVisitedAt: (row["lastVisitedAt"] as! String).toDate(),
                    content: row["content"] as! String,
                    type: 1,
                    notifiedAt: (row["notifiedAt"] as! String).toDate())
                if !global.inboxData.notifications.contains(where: { $0.notificationId == notificationData.notificationId }) &&
                    !newInboxNotifications.contains(where: { $0.notificationId == notificationData.notificationId }) {
                    newInboxNotifications.append(notificationData)
                }
            }
        }
        
        if let comments = json["comments"] as? NSDictionary {
            for i in 1...comments.count {
                let row = comments[String(i)] as! NSDictionary
                let notificationData = NotificationData(
                    notificationId: row["notificationId"] as! String,
                    byteId: row["byteId"] as! String,
                    buddyId: row["buddyId"] as! String,
                    buddyUsername: row["buddyUsername"] as! String,
                    lastVisitedAt: (row["lastVisitedAt"] as! String).toDate(),
                    content: row["content"] as! String,
                    type: 2,
                    notifiedAt: (row["notifiedAt"] as! String).toDate())
                if !global.inboxData.notifications.contains(where: { $0.notificationId == notificationData.notificationId }) &&
                    !newInboxNotifications.contains(where: { $0.notificationId == notificationData.notificationId }) {
                    newInboxNotifications.append(notificationData)
                }
            }
        }
        
        if let replies = json["replies"] as? NSDictionary {
            for i in 1...replies.count {
                let row = replies[String(i)] as! NSDictionary
                let notificationData = NotificationData(
                    notificationId: row["notificationId"] as! String,
                    byteId: row["byteId"] as! String,
                    buddyId: row["buddyId"] as! String,
                    buddyUsername: row["buddyUsername"] as! String,
                    lastVisitedAt: (row["lastVisitedAt"] as! String).toDate(),
                    content: row["content"] as! String,
                    type: 3,
                    notifiedAt: (row["notifiedAt"] as! String).toDate())
                if !global.inboxData.notifications.contains(where: { $0.notificationId == notificationData.notificationId }) &&
                    !newInboxNotifications.contains(where: { $0.notificationId == notificationData.notificationId }) {
                    newInboxNotifications.append(notificationData)
                }
            }
        }
        
        newInboxNotifications.sort { $0.notifiedAt < $1.notifiedAt }
        global.inboxData.notifications.append(contentsOf: newInboxNotifications)
    }
    
    func getMessages(json: NSDictionary) {
        // myMessages is unnecessary unless deleted chat history must be restored by setting lastSyncedAt to the past.
        if let myMessages = json["myMessages"] as? NSDictionary {
            var buddyIds = [String]()
            
            for i in 1...myMessages.count {
                let row = myMessages[String(i)] as! NSDictionary
                let messageData = MessageData(
                    messageId: row["messageId"] as! String,
                    isMine: true,
                    isSending: false,
                    sentAt: (row["sentAt"] as! String).toDate(),
                    content: row["content"] as! String)
                
                let buddyId = row["buddyId"] as! String
                if !buddyIds.contains(buddyId) {
                    buddyIds.append(buddyId)
                }
                
                if global.chatData[buddyId] == nil {
                    let buddyUsername = row["buddyUsername"] as! String
                    global.chatData[buddyId] = ChatRoomData(username: buddyUsername, messageData: messageData)
                } else if !global.chatData[buddyId]!.messages.contains(where: { $0.messageId == messageData.messageId }) {
                    global.chatData[buddyId]!.messages.append(messageData)
                }
            }
        }
        
        if let messages = json["messages"] as? NSDictionary {
            var buddyIds = [String]()
            
            for i in 1...messages.count {
                let row = messages[String(i)] as! NSDictionary
                let messageData = MessageData(
                    messageId: row["messageId"] as! String,
                    isMine: false,
                    isSending: false,
                    sentAt: (row["sentAt"] as! String).toDate(),
                    content: row["content"] as! String)
                
                let buddyId = row["buddyId"] as! String
                if !buddyIds.contains(buddyId) {
                    buddyIds.append(buddyId)
                }
                
                if global.chatData[buddyId] == nil {
                    let buddyUsername = row["buddyUsername"] as! String
                    global.chatData[buddyId] = ChatRoomData(username: buddyUsername, messageData: messageData)
                } else if !global.chatData[buddyId]!.messages.contains(where: { $0.messageId == messageData.messageId }) {
                    global.chatData[buddyId]!.messages.append(messageData)
                }
            }
            
            for buddyId in buddyIds {
                global.chatData[buddyId]!.messages.sort { $0.sentAt < $1.sentAt }
                
                if buddyId == global.chatBuddyId &&
                    UIApplication.shared.applicationState == .active {
                    global.chatData[buddyId]!.lastMyReadAt = global.getUtcTime()
                    global.updateBadges()
                    global.firebaseUser!.getIDToken(completion: { (token, error) in
                        let postString =
                            "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                            "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                            "buddyId=\(buddyId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
                        global.runPhp(script: "readMessages", postString: postString) { json in
                            global.db.collection("accounts")
                                .document(buddyId)
                                .setData(["hasChanged": true], merge: true) { error in }
                        }
                    })
                }
            }
        }
    }
    
    func getReadReceipts(json: NSDictionary) {
        if let readReceipts = json["readReceipts"] as? NSDictionary {
            for i in 1...readReceipts.count {
                let row = readReceipts[String(i)] as! NSDictionary
                let buddyId = row["buddyId"] as! String
                let lastReadAt = (row["lastReadAt"] as! String).toDate()
                if global.chatData[buddyId] != nil {
                    global.chatData[buddyId]!.lastBuddyReadAt = lastReadAt
                }
            }
        }
    }
    
    func getUser(completion: @escaping () -> Void) {
        global.firebaseUser!.getIDToken(completion: { (token, error) in
            let postString =
                "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
            global.runPhp(script: "getUser", postString: postString) { json in
                global.username = json["username"] as! String
                global.smallImage = json["smallImage"] as! String
                global.bigImage = json["bigImage"] as! String
                global.genderIndex = json["gender"] as! Int
                global.birthday = (json["birthday"] as! String).toDate(fromFormat: "yyyy-MM-dd")
                global.countryIndex = json["country"] as! Int
                global.interests = (json["interests"] as! String).toInterestsArray()
                global.otherInterests = json["otherInterests"] as! String
                global.intro = json["intro"] as! String
                global.github = json["github"] as! String
                global.linkedin = json["linkedin"] as! String
                
                global.notifyLikes = json["notifyLikes"] as! Bool
                global.notifyComments = json["notifyComments"] as! Bool
                global.notifyMessages = json["notifyMessages"] as! Bool
                global.bytesMade = json["bytesMade"] as! Int
                global.commentsMade = json["commentsMade"] as! Int
                global.byteLikesGiven = json["byteLikesGiven"] as! Int
                global.commentLikesGiven = json["commentLikesGiven"] as! Int

                global.blockedBuddyIds = [String]()
                // If the json is empty, it will be NSArray. Otherwise, it will be NSDictionary. So there's no need to make sure its count is > 0.
                if let blockedBuddyIds = json["blockedBuddyIds"] as? NSDictionary {
                    for i in 1...blockedBuddyIds.count {
                        let row = blockedBuddyIds[String(i)] as! NSDictionary
                        global.blockedBuddyIds.append(row["buddyId"] as! String)
                    }
                }
                
                completion()
            }
        })
    }
}
