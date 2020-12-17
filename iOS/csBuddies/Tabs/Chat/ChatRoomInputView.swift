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
                        sendMessage()
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
            case .tooManyChatRoomsToday:
                return Alert(title: Text("Reached Daily New Chat Limit"), message: Text("You already made 50 new chat rooms today. Please come back tomorrow."), dismissButton: .default(Text("OK")))
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
            if json["canChat"] != nil {
                activeAlert = .tooManyChatRoomsToday
                return
            }
            
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
