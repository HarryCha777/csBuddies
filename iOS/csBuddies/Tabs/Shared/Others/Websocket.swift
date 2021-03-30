//
//  Websocket.swift
//  csBuddies
//
//  Created by Harry Cha on 3/20/21.
//  Copyright © 2021 Harry Cha. All rights reserved.
//

import SwiftUI

class Websocket: ObservableObject {
    var webSocketTask: URLSessionWebSocketTask?
    weak var timer: Timer?
    
    init?() {
        if webSocketTask != nil && timer != nil {
            disconnect()
        }
        
        globalObject.firebaseUser!.getIDToken(completion: { (token, error) in
            let script = "channelListener"
            let postString =
                "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
            
            let scriptUrl = URL(string: "ws://\(globalObject.webServerLink)/\(script)/?\(postString)");
            var request = URLRequest(url: scriptUrl!)
            request.httpMethod = "GET"
            
            self.webSocketTask = URLSession.shared.webSocketTask(with: request)
            self.webSocketTask!.resume()
            self.ping()
            self.listen()
        })
    }
    
    func disconnect() {
        timer?.invalidate()
        webSocketTask!.cancel(with: .goingAway, reason: nil)
    }
    
    func ping() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { (_) in
            self.webSocketTask!.send(URLSessionWebSocketTask.Message.string("ping")) { error in }
        }
    }
    
    func listen() {
        webSocketTask!.receive { result in
            switch result {
            case .failure(_):
                break
            case .success(let message):
                switch message {
                case .string(let messageString):
                    if messageString == "sync" {
                        globalObject.firebaseUser!.getIDToken(completion: { (token, error) in
                            let postString =
                                "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
                            globalObject.runHttp(script: "syncUser", postString: postString) { json in
                                globalObject.isAdmin = json["isAdmin"] as! Bool
                                if json["isClientOutdated"] as! Bool {
                                    globalObject.username = ""
                                    globalObject.activeRootView = .loading
                                }
                                if json["hasInteraction"] as! Bool == false {
                                    return
                                }
                                
                                globalObject.byteLikesReceived = json["byteLikesReceived"] as! Int
                                globalObject.commentLikesReceived = json["commentLikesReceived"] as! Int
                                
                                self.getInboxNotifications(json: json)
                                self.getMessages(json: json)
                                self.getReadReceipts(json: json)
                            }
                        })
                    }
                case .data(_):
                    break
                @unknown default:
                    fatalError()
                }
                
                self.listen()
            }
        }
    }
    
    func getInboxNotifications(json: NSDictionary) {
        var newInboxNotifications = [NotificationData]()
        
        if let byteLikes = json["byteLikes"] as? NSArray {
            for i in 0...byteLikes.count - 1 {
                let row = byteLikes[i] as! NSDictionary
                let notificationData = NotificationData(
                    notificationId: row["notificationId"] as! String,
                    byteId: row["byteId"] as! String,
                    buddyId: row["buddyId"] as! String,
                    buddyUsername: row["buddyUsername"] as! String,
                    lastVisitedAt: (row["lastVisitedAt"] as! String).toDate(),
                    content: row["content"] as! String,
                    type: 0,
                    notifiedAt: (row["notifiedAt"] as! String).toDate())
                if !globalObject.inboxData.notifications.contains(where: { $0.notificationId == notificationData.notificationId }) &&
                    !newInboxNotifications.contains(where: { $0.notificationId == notificationData.notificationId }) {
                    newInboxNotifications.append(notificationData)
                }
            }
        }
        
        if let byteLikes = json["commentLikes"] as? NSArray {
            for i in 0...byteLikes.count - 1 {
                let row = byteLikes[i] as! NSDictionary
                let notificationData = NotificationData(
                    notificationId: row["notificationId"] as! String,
                    byteId: row["byteId"] as! String,
                    buddyId: row["buddyId"] as! String,
                    buddyUsername: row["buddyUsername"] as! String,
                    lastVisitedAt: (row["lastVisitedAt"] as! String).toDate(),
                    content: row["content"] as! String,
                    type: 1,
                    notifiedAt: (row["notifiedAt"] as! String).toDate())
                if !globalObject.inboxData.notifications.contains(where: { $0.notificationId == notificationData.notificationId }) &&
                    !newInboxNotifications.contains(where: { $0.notificationId == notificationData.notificationId }) {
                    newInboxNotifications.append(notificationData)
                }
            }
        }
        
        if let comments = json["comments"] as? NSArray {
            for i in 0...comments.count - 1 {
                let row = comments[i] as! NSDictionary
                let notificationData = NotificationData(
                    notificationId: row["notificationId"] as! String,
                    byteId: row["byteId"] as! String,
                    buddyId: row["buddyId"] as! String,
                    buddyUsername: row["buddyUsername"] as! String,
                    lastVisitedAt: (row["lastVisitedAt"] as! String).toDate(),
                    content: row["content"] as! String,
                    type: 2,
                    notifiedAt: (row["notifiedAt"] as! String).toDate())
                if !globalObject.inboxData.notifications.contains(where: { $0.notificationId == notificationData.notificationId }) &&
                    !newInboxNotifications.contains(where: { $0.notificationId == notificationData.notificationId }) {
                    newInboxNotifications.append(notificationData)
                }
            }
        }
        
        if let replies = json["replies"] as? NSArray {
            for i in 0...replies.count - 1 {
                let row = replies[i] as! NSDictionary
                let notificationData = NotificationData(
                    notificationId: row["notificationId"] as! String,
                    byteId: row["byteId"] as! String,
                    buddyId: row["buddyId"] as! String,
                    buddyUsername: row["buddyUsername"] as! String,
                    lastVisitedAt: (row["lastVisitedAt"] as! String).toDate(),
                    content: row["content"] as! String,
                    type: 3,
                    notifiedAt: (row["notifiedAt"] as! String).toDate())
                if !globalObject.inboxData.notifications.contains(where: { $0.notificationId == notificationData.notificationId }) &&
                    !newInboxNotifications.contains(where: { $0.notificationId == notificationData.notificationId }) {
                    newInboxNotifications.append(notificationData)
                }
            }
        }
        
        newInboxNotifications.sort { $0.notifiedAt < $1.notifiedAt }
        globalObject.inboxData.notifications.append(contentsOf: newInboxNotifications)
    }
    
    func getMessages(json: NSDictionary) {
        // myMessages is unnecessary unless deleted chat history must be restored by setting lastSyncedAt to the past.
        if let myMessages = json["myMessages"] as? NSArray {
            var buddyIds = [String]()
            
            for i in 0...myMessages.count - 1 {
                let row = myMessages[i] as! NSDictionary
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
                
                if globalObject.chatData[buddyId] == nil {
                    let buddyUsername = row["buddyUsername"] as! String
                    globalObject.chatData[buddyId] = ChatRoomData(username: buddyUsername, messageData: messageData)
                } else if !globalObject.chatData[buddyId]!.messages.contains(where: { $0.messageId == messageData.messageId }) {
                    globalObject.chatData[buddyId]!.messages.append(messageData)
                }
            }
        }
        
        if let messages = json["messages"] as? NSArray {
            var buddyIds = [String]()
            
            for i in 0...messages.count - 1 {
                let row = messages[i] as! NSDictionary
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
                
                if globalObject.chatData[buddyId] == nil {
                    let buddyUsername = row["buddyUsername"] as! String
                    globalObject.chatData[buddyId] = ChatRoomData(username: buddyUsername, messageData: messageData)
                } else if !globalObject.chatData[buddyId]!.messages.contains(where: { $0.messageId == messageData.messageId }) {
                    globalObject.chatData[buddyId]!.messages.append(messageData)
                }
            }
            
            for buddyId in buddyIds {
                globalObject.chatData[buddyId]!.messages.sort { $0.sentAt < $1.sentAt }
                
                if buddyId == globalObject.chatBuddyId &&
                    UIApplication.shared.applicationState == .active {
                    globalObject.chatData[buddyId]!.lastMyReadAt = globalObject.getUtcTime()
                    globalObject.updateBadges()
                    globalObject.firebaseUser!.getIDToken(completion: { (token, error) in
                        let postString =
                            "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                            "buddyId=\(buddyId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
                        globalObject.runHttp(script: "readMessages", postString: postString) { json in }
                    })
                }
            }
        }
    }
    
    func getReadReceipts(json: NSDictionary) {
        if let readReceipts = json["readReceipts"] as? NSArray {
            for i in 0...readReceipts.count - 1 {
                let row = readReceipts[i] as! NSDictionary
                let buddyId = row["buddyId"] as! String
                let lastReadAt = (row["lastReadAt"] as! String).toDate()
                if globalObject.chatData[buddyId] != nil {
                    globalObject.chatData[buddyId]!.lastBuddyReadAt = lastReadAt
                }
            }
        }
    }
}
