//
//  MessageInputView.swift
//  csBuddies
//
//  Created by Harry Cha on 6/16/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase

struct MessageInputView: View {
    @EnvironmentObject var global: Global
    
    let buddyId: String
    let buddyUsername: String
    @State var message: String
    
    @State private var dailyLimit = 0

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
                        .frame(maxHeight: 70)
                        .padding(.horizontal, 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
                
                Button(action: {
                    if message.count > 1000 {
                        activeAlert = .tooLongMessage
                    } else {
                        sendMessage()
                    }
                }) {
                    VStack {
                        Image(systemName: "paperplane.fill")
                    }
                    .font(.title)
                }
                .disabled(message.count == 0)
                .padding(.vertical, 4)
            }
            .padding(.horizontal)
            
            Spacer()
                .frame(height: 5)
        }
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .tooLongMessage:
                return Alert(title: Text("Too Long Message"), message: Text("You currently typed \(message.count) characters. Please type no more than 1,000 characters."), dismissButton: .default(Text("OK")))
            case .tooManyChatRoomsToday:
                return Alert(title: Text("Reached Daily Chat Buddies Limit"), message: Text("You already sent messages to \(dailyLimit) different buddies today. Please come back tomorrow."), dismissButton: .default(Text("OK")))
            }
        }
        .onDisappear {
            // Rapidly updating a global variable is laggy in TabView with lots of content,
            // so use a local variable instead and update the global variable only at the end.
            global.messageDrafts[buddyId] = message
        }
    }
    
    func sendMessage() {
        let tempMessageId = UUID().uuidString
        let messageData = MessageData(
            messageId: tempMessageId,
            isMine: true,
            isSending: true,
            sentAt: global.getUtcTime(),
            content: message)

        if global.chatData[buddyId] == nil {
            global.chatData[buddyId] = ChatRoomData(username: buddyUsername, messageData: messageData)
        } else {
            global.chatData[buddyId]!.messages.append(messageData)
        }

        let originalMessage = message
        message = ""
        
        global.firebaseUser!.getIDToken(completion: { (token, error) in
            let postString =
                "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "buddyId=\(buddyId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "content=\(originalMessage.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
            global.runPhp(script: "addMessage", postString: postString) { json in
                if json["isTooMany"] != nil &&
                    json["isTooMany"] as! Bool {
                    message = originalMessage
                    global.chatData[buddyId] = nil
                    dailyLimit = json["dailyLimit"] as! Int
                    activeAlert = .tooManyChatRoomsToday
                    return
                }
                
                let now = global.getUtcTime()
                let index = global.chatData[buddyId]!.messages.firstIndex(where: { $0.messageId == tempMessageId })
                global.chatData[buddyId]!.messages[index!].messageId = json["messageId"] as! String
                global.chatData[buddyId]!.messages[index!].isSending = false
                global.chatData[buddyId]!.messages[index!].sentAt = now
                
                global.db.collection("accounts")
                    .document(buddyId)
                    .setData(["hasChanged": true], merge: true) { error in }
            }
        })
    }
}
