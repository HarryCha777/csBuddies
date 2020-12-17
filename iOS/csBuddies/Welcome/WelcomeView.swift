//
//  WelcomeView.swift
//  csBuddies
//
//  Created by Harry Cha on 11/12/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase

struct WelcomeView: View {
    @EnvironmentObject var global: Global
    @FetchRequest(entity: User.entity(), sortDescriptors: []) var users: FetchedResults<User>
    
    var body: some View {
        WelcomeAnimationView()
            .onAppear {
                loadUserData()
                global.hasUserDataLoaded = true
                if global.myId != "" {
                    listenToMessageUpdates()
                }
                if global.hasSignedIn {
                    signIn()
                    global.hasSignedIn = false
                } else {
                    global.activeRootView = .tabs
                }
            }
    }
    
    func loadUserData() {
        // Find user.
        let moc = PersistenceController.shared.container.viewContext
        let index = users.firstIndex(where: { $0.myId == global.myId })

        if index == nil {
            let user = User(context: moc)
            user.myId = global.myId
            try? moc.save()
            return
        }
        
        let user = users[index!]

        // Save client data, which may not be up to date if the app was previously crashed or reinstalled.
        global.buddiesFilterGenderIndex = Int(user.buddiesFilterGenderIndex)
        global.buddiesFilterMinAge = Int(user.buddiesFilterMinAge)
        global.buddiesFilterMaxAge = Int(user.buddiesFilterMaxAge)
        if global.buddiesFilterMinAge < 13 || global.buddiesFilterMinAge > 130 ||
            global.buddiesFilterMaxAge < 13 || global.buddiesFilterMaxAge > 130 ||
            global.buddiesFilterMinAge > global.buddiesFilterMaxAge {
            global.buddiesFilterMinAge = 13
            global.buddiesFilterMaxAge = 130
        }
        global.buddiesFilterCountryIndex = Int(user.buddiesFilterCountryIndex)
        global.buddiesFilterInterests = user.buddiesFilterInterests as? [String] ?? [String]()
        global.buddiesFilterSortIndex = Int(user.buddiesFilterSortIndex)
        global.bytesFilterSortIndex = Int(user.bytesFilterSortIndex)
        global.bytesFilterTimeIndex = Int(user.bytesFilterTimeIndex)
        global.byteDraft = user.byteDraft ?? ""
        global.messageDrafts = user.messageDrafts as? [String: String] ?? [String: String]()
        global.firstLaunchTime = user.firstLaunchTime ?? global.getUtcTime()
        global.hasAskedReview = user.hasAskedReview
        global.hasAskedNotification = user.hasAskedNotification
        global.hasByteNotification = user.hasByteNotification
        global.hasChatNotification = user.hasChatNotification
        
        do {
            global.savedUsers = try JSONDecoder().decode([UserRowData].self, from: user.savedUsersBinaryData ?? Data())
            global.savedBytes = try JSONDecoder().decode([BytesPostData].self, from: user.savedBytesBinaryData ?? Data())
            global.chatData = try JSONDecoder().decode([String: ChatRoomData].self, from: user.chatBinaryData ?? Data())
        } catch {}

        // Save server data, which will always be in sync.
        if !global.mustSyncWithServer {
            global.email = user.email ?? ""
            global.username = user.username ?? ""
            global.smallImage = user.smallImage ?? ""
            global.bigImage = user.bigImage ?? ""
            global.genderIndex = Int(user.genderIndex)
            global.birthday = user.birthday ?? Date(timeIntervalSince1970: 946684800) // Default birthday is 1/1/2000 12:00:00 AM UTC.
            global.countryIndex = Int(user.countryIndex)
            global.interests = user.interests as? [String] ?? [String]()
            global.otherInterests = user.otherInterests ?? ""
            global.intro = user.intro ?? ""
            global.gitHub = user.gitHub ?? ""
            global.linkedIn = user.linkedIn ?? ""
            global.bytesMade = Int(user.bytesMade)
            global.likesGiven = Int(user.likesGiven)
            global.lastReceivedChatTime = user.lastReceivedChatTime ?? global.getUtcTime()
            
            do {
                global.blocks = try JSONDecoder().decode([UserRowData].self, from: user.blocksBinaryData ?? Data())
            } catch {}
        }
        
        global.mustSyncWithServer = false
    }
    
    func signIn() {
        let postString =
            "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "password=\(global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "fcm=\(Messaging.messaging().fcmToken!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
        global.runPhp(script: "signIn", postString: postString) { json in }
    }

    func listenToMessageUpdates() {
        if global.isMessageUpdatesListenerSetUp {
            return
        }
        global.isMessageUpdatesListenerSetUp = true

        global.messageUpdatesListener = global.db.collection("messageUpdates")
            .whereField("buddyId", isEqualTo: global.myId)
            .addSnapshotListener { [self] (snapshot, error) in
                if snapshot != nil {
                    snapshot!
                        .documentChanges
                        .forEach { documentChange in
                            if documentChange.type == .added ||
                                documentChange.type == .modified {
                                let buddyId = documentChange.document.get("myId") as! String
                                let buddyUsername = documentChange.document.get("myUsername") as! String
                                let lastBuddyReadTime = (documentChange.document.get("lastReadTime") as! Timestamp).dateValue()
                                let lastBuddySendTime = (documentChange.document.get("lastSendTime") as! Timestamp).dateValue()

                                if global.chatData[buddyId] == nil {
                                    global.chatData[buddyId] = ChatRoomData(username: buddyUsername)
                                } else if global.chatData[buddyId]!.username != buddyUsername {
                                    global.chatData[buddyId]?.username = buddyUsername
                                }
                                
                                var mustUpdateBadges = false
                                if global.chatData[buddyId]!.lastBuddyReadTime < lastBuddyReadTime {
                                    global.chatData[buddyId]?.lastBuddyReadTime = lastBuddyReadTime
                                    for index in global.chatData[buddyId]!.messages.indices {
                                        if !global.chatData[buddyId]!.messages[index].isMine &&
                                            global.chatData[buddyId]!.messages[index].sendTime <= lastBuddyReadTime {
                                            mustUpdateBadges = true
                                        }
                                    }
                                }
                                
                                if global.chatData[buddyId]!.lastBuddySendTime < lastBuddySendTime {
                                    getMessages(buddyId: buddyId, lastBuddySendTime: lastBuddyReadTime, mustUpdateBadges: mustUpdateBadges)
                                }
                            }
                    }
                }
        }
    }
    
    func getMessages(buddyId: String, lastBuddySendTime: Date, mustUpdateBadges: Bool) {
        let postString =
            "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "password=\(global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "buddyId=\(buddyId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "lastReceivedChatTime=\(global.lastReceivedChatTime.toString())"
        global.runPhp(script: "getMessages", postString: postString) { json in
            if json.count == 0 {
                // Prevent empty ChatRoomData on app launch if ChatRoomData has been deleted previously but messageUpdates Firestore documents remain.
                if global.chatData[buddyId]!.messages.count == 0 {
                    global.chatData[buddyId] = nil
                }
                return
            }
            
            for i in 1...json.count {
                let row = json[String(i)] as! NSDictionary
                let chatRoomMessageData = ChatRoomMessageData(
                    messageId: row["messageId"] as! String,
                    isMine: false,
                    sendTime: (row["sendTime"] as! String).toDate(),
                    content: row["content"] as! String)
                
                // Append only if it's a new message since same messages may be fetched by both .added and .modified.
                if !global.chatData[buddyId]!.messages.contains(where: { $0.messageId == chatRoomMessageData.messageId }) {
                    global.chatData[buddyId]!.messages.append(chatRoomMessageData)
                }
            }
            global.lastReceivedChatTime = global.getUtcTime()
            global.chatData[buddyId]!.lastBuddySendTime = lastBuddySendTime
            
            if global.chatBuddyId == buddyId &&
                UIApplication.shared.applicationState == .active {
                let now = global.getUtcTime()
                global.chatData[buddyId]!.lastMyReadTime = now
                global.updateBadges()
                global.db.collection("messageUpdates")
                    .whereField("myId", isEqualTo: global.myId)
                    .whereField("buddyId", isEqualTo: buddyId)
                    .getDocuments { (snapshot, error) in
                        if snapshot!.documents.count == 0 {
                            global.db.collection("messageUpdates")
                                .addDocument(data: [
                                                "myId": global.myId,
                                                "myUsername": global.username,
                                                "buddyId": buddyId,
                                                "lastReadTime": now,
                                                "lastSendTime": Date(timeIntervalSince1970: 0)])
                        } else {
                            snapshot!.documents[0].reference
                                .setData(["myUsername": global.username, "lastReadTime": now], merge: true)
                        }
                    }
            }
        }
    }
}
