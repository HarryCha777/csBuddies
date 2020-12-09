//
//  ChatRoomInputView.swift
//  csBuddies
//
//  Created by Harry Cha on 6/16/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase

struct ChatRoomInputView: View {
    @EnvironmentObject var global: Global
    
    let buddyId: String
    let buddyUsername: String
    @State var message: String
    @State private var isMessaging = false
    
    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            tooLongMessage,
            isBlocked,
            tooManyChatRoomsToday
    }

    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                VStack {
                    BetterTextEditor(placeholder: "Enter message here...", text: $message)
                        .onChange(of: self.message) { newMessage in
                            // Use onChange since @Binding does not work with dictionaries and didSet does not work with @State.
                            global.messageDrafts[buddyId] = newMessage
                        }
                        .frame(maxHeight: 70)
                        .padding(.horizontal, 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
                
                Button(action: {
                    isMessaging = true

                    if message.count > 1000 {
                        activeAlert = .tooLongMessage
                    } else {
                        isBlocked() { isBlocked in
                            if isBlocked {
                                activeAlert = .isBlocked
                            } else {
                                madeTooManyChatRoomsToday() { madeTooManyChatRoomsToday in
                                    if madeTooManyChatRoomsToday {
                                        activeAlert = .tooManyChatRoomsToday
                                    } else {
                                        sendMessage()
                                    }
                                }
                            }
                        }
                    }
                }) {
                    VStack {
                        if !isMessaging {
                            Image(systemName: "paperplane.fill")
                        } else {
                            ActivityIndicatorView()
                                .padding(.horizontal, -4)
                        }
                    }
                    .font(.title)
                }
                .disabled(message.count == 0 || isMessaging)
                .padding(.vertical, 4)
            }
            .padding(.horizontal)
            
            Spacer()
                .frame(height: 5)
        }
        .alert(item: $activeAlert) { alert in
            DispatchQueue.main.async {
                isMessaging = false
            }

            switch alert {
            case .tooLongMessage:
                return Alert(title: Text("Too Long Message"), message: Text("You currently typed \(message.count) characters. Please type no more than 1,000 characters."), dismissButton: .default(Text("OK")))
            case .isBlocked:
                return Alert(title: Text("You are Blocked"), message: Text("The receiver blocked you."), dismissButton: .default(Text("OK")))
            case .tooManyChatRoomsToday:
                return Alert(title: Text("Reached Daily New Chat Limit"), message: Text("You already made 50 new chat rooms today. Please come back tomorrow."), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func madeTooManyChatRoomsToday(completion: @escaping (Bool) -> Void) {
        if global.isPremium || global.chatData[buddyId] != nil {
            completion(false)
            return
        }
        
        if Calendar.current.isDate(global.getUtcTime(), inSameDayAs: global.lastFirstChatTime) {
            if global.firstChatsToday < 50 {
                global.firstChatsToday += 1
                let postString =
                    "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                    "password=\(global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                    "firstChatsToday=\(global.firstChatsToday + 1)"
                global.runPhp(script: "updateFirstChatsToday", postString: postString) { json in }
                completion(false)
            } else {
                completion(true)
            }
        } else {
            global.lastFirstChatTime = global.getUtcTime()
            global.firstChatsToday = 1
            let postString =
                "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "password=\(global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "firstChatsToday=1"
            global.runPhp(script: "updateFirstChatsToday", postString: postString) { json in }
            completion(false)
        }
    }
    
    func isBlocked(completion: @escaping (Bool) -> Void) {
        let postString =
            "buddyId=\(buddyId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "password=\(global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
        global.runPhp(script: "isBlocked", postString: postString) { json in
            let isBlocked = json["isBlocked"] as! Bool
            if isBlocked {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func sendMessage() {
        let postString =
            "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "password=\(global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "buddyId=\(buddyId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "content=\(message.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
        global.runPhp(script: "addMessage", postString: postString) { json in
            let now = global.getUtcTime()
            let chatRoomMessageData = ChatRoomMessageData(
                messageId: json["messageId"] as! String,
                isMine: true,
                sendTime: now,
                content: message)
            
            if global.chatData[buddyId] == nil {
                global.chatData[buddyId] = ChatRoomData(username: buddyUsername)
            }
            global.chatData[buddyId]!.messages.append(chatRoomMessageData)

            // Read buddy's FCM each time since it might have been changed if buddy reinstalled this app.
            let fcm = json["fcm"] as! String
            let badges = json["badges"] as! Int
            global.sendNotification(body: message, fcm: fcm, badges: badges, type: "chat")
            
            message = ""
            isMessaging = false
            
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
                                            "lastReadTime": Date(timeIntervalSince1970: 0),
                                            "lastSendTime": now])
                    } else {
                        snapshot!.documents[0].reference
                            .setData(["myUsername": global.username, "lastSendTime": now], merge: true)
                    }
                }
        }
    }
}
