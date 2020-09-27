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
    
    let buddyUsername: String
    private struct AlertId: Identifiable {
        enum Id {
            case
            tooLongMessage,
            isBlocked,
            tooManyChatRoomsToday,
            prepermission
        }
        var id: Id
    }
    private let firebaseServerKey = "INSERT FIREBASE SERVER KEY HERE"

    @State private var message = ""
    @State private var isMessaging = false
    @State private var alertId: AlertId?

    var body: some View {
        HStack {
            TextField("Enter message here...", text: $message)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button(action: {
                self.isMessaging = true
                
                if self.message.count > 1000 {
                    self.alertId = AlertId(id: .tooLongMessage)
                } else {
                    self.isBlocked() { (isBlocked) in
                        if isBlocked {
                            self.alertId = AlertId(id: .isBlocked)
                        } else {
                            self.madeTooManyChatRoomsToday() { (madeTooManyChatRoomsToday) in
                                if madeTooManyChatRoomsToday {
                                    self.alertId = AlertId(id: .tooManyChatRoomsToday)
                                } else {
                                    self.sendMessage()
                                }
                            }
                        }
                    }
                }
            }) {
                Image(systemName: "paperplane.fill")
                    .font(.title)
                    .alert(item: $alertId) { alert in
                        DispatchQueue.main.async {
                            self.isMessaging = false
                        }
                        
                        switch alert.id {
                        case .tooLongMessage:
                            return Alert(title: Text("Too Long Message"), message: Text("You currently typed \(self.message.count) characters. Please type no more than 1,000 characters."), dismissButton: .default(Text("OK")))
                        case .isBlocked:
                            return Alert(title: Text("You are Blocked"), message: Text("The receiver blocked you."), dismissButton: .default(Text("OK")))
                        case .tooManyChatRoomsToday:
                            return Alert(title: Text("Three or More Chat Rooms Today"), message: Text("To create 3 or more chat rooms today, you need to watch one ad each time."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("OK"), action: {
                                if self.global.admobRewardedAdsNewChat.rewardedAd.isReady {
                                    self.global.admobRewardedAdsNewChat.showAd(rewardFunction: {
                                        self.sendMessage()
                                    })
                                } else {
                                    self.sendMessage()
                                }
                            }))
                        case .prepermission:
                            return Alert(title: Text("Get notified when you get a response!"),
                                         message: Text("Would you like to receive a notification when you receive text messages?"),
                                         primaryButton: .destructive(Text("Not Now")),
                                         secondaryButton: .default(Text("Notify Me"), action: {
                                            self.global.requestPermission()
                                         }))
                        }
                }
            }
            .disabled(message.count == 0 || isMessaging)
        }
        .frame(minHeight: 45)
        .padding(.horizontal)
    }
    
    func madeTooManyChatRoomsToday(completion: @escaping (Bool) -> Void) {
        if self.global.isPremium || global.chatHistory[buddyUsername] != nil {
            completion(false)
            return
        }
        
        let postString =
            "username=\(global.username.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "password=\(global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "hasImage=false"
        global.runPhp(script: "getUser", postString: postString) { json in
            let lastNewChat = (json["lastNewChat"] as! String).toDate(fromFormat: "yyyy-MM-dd HH:mm:ss")
            let newChats = json["newChats"] as! Int
            
            if Calendar.current.isDate(self.global.getUtcTime(), inSameDayAs: lastNewChat) {
                if newChats < 2 {
                    let postString =
                        "username=\(self.global.username.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                        "password=\(self.global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                        "newChats=\(newChats + 1)"
                    self.global.runPhp(script: "updateNewChats", postString: postString) { json in }
                    completion(false)
                } else {
                    completion(true)
                }
            } else {
                let postString =
                    "username=\(self.global.username.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                    "password=\(self.global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                    "newChats=1"
                self.global.runPhp(script: "updateNewChats", postString: postString) { json in }
                completion(false)
            }
        }
    }
    
    func isBlocked(completion: @escaping (Bool) -> Void) {
        let postString =
            "buddyUsername=\(buddyUsername.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "username=\(global.username.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
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
        let now = global.getUtcTime()
        let documentId = now.toString(toFormat: "yyyy-MM-dd HH:mm:ss.SSS")
        // this format does not seem to work for all users
        
        global.db.collection("messages")
            .document(documentId)
            .setData([
                "id": documentId,
                "sender": global.username,
                "receiver": buddyUsername,
                "sentTime": now,
                "content": message,
                "isRead": false,
                "isDeleted": false])
        
        let chatRoomMessageData = ChatRoomMessageData(
            id: documentId,
            sender: global.username,
            receiver: buddyUsername,
            sentTime: now,
            content: message,
            isRead: false,
            isDeleted: false)
        
        if global.chatHistory[buddyUsername] != nil {
            global.chatHistory[buddyUsername]!.append(chatRoomMessageData)
        } else {
            global.chatHistory[buddyUsername] = [chatRoomMessageData]
            if global.buddyImageList[buddyUsername] == nil {
                let postString =
                    "username=\(buddyUsername.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                    "hasImage=true"
                global.runPhp(script: "getOtherUser", postString: postString) { json in
                    self.global.buddyImageList[self.buddyUsername] = (json["image"] as! String)
                }
            }
        }
        sendNotification()
    }
    
    func sendNotification() {
        let postString =
            "username=\(buddyUsername.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "hasImage=false"
        global.runPhp(script: "getOtherUser", postString: postString) { json in
            // Read receiver's FCM each time since it might have been changed if receiver reinstalled app.
            let fcm = json["fcm"] as! String
            let badges = json["badges"] as! Int

            let postString =
                "username=\(self.buddyUsername.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "badges=\(badges + 1)"
            self.global.runPhp(script: "updateBadges", postString: postString) { json in }

            let urlString = "https://fcm.googleapis.com/fcm/send"
            let url = NSURL(string: urlString)!
            let params: [String: Any] = ["to": fcm,
                                         "priority": "high",
                                         "notification": ["title": self.global.username, "body": self.message, "badge": badges + 1]
            ]
            self.message = ""
            
            let request = NSMutableURLRequest(url: url as URL)
            request.httpMethod = "POST"
            request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [.prettyPrinted])
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("key=\(self.firebaseServerKey)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in
                self.isMessaging = false
            
                self.global.hasDeterminedPermission() { hasDeterminedPermission in
                    if !hasDeterminedPermission && !Calendar.current.isDate(self.global.getUtcTime(), inSameDayAs: self.global.lastShownPrepermissionAlertInChatRoomView) {
                        DispatchQueue.main.async {
                            self.global.lastShownPrepermissionAlertInChatRoomView = self.global.getUtcTime()
                            self.alertId = AlertId(id: .prepermission)
                        }
                    }
                }
            }
            task.resume()
        }
    }
}

struct ChatRoomInputView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomInputView(buddyUsername: "")
    }
}
