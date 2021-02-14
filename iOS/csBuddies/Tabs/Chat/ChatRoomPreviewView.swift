//
//  ChatRoomLinkView.swift
//  csBuddies
//
//  Created by Harry Cha on 6/6/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct ChatRoomPreviewView: View {
    @EnvironmentObject var global: Global

    let chatRoomPreviewData: ChatRoomPreviewData
    
    var body: some View {
        // Check messages.last != nil instead of messages.count > 0 since latter may crash when chat rooms are deleted.
        if global.chatData[chatRoomPreviewData.buddyId] != nil && global.chatData[chatRoomPreviewData.buddyId]!.messages.last != nil {
            HStack {
                NavigationLinkBorderless(destination: UserView(userId: chatRoomPreviewData.buddyId)) {
                    SmallImageView(userId: chatRoomPreviewData.buddyId, isOnline: global.isOnline(lastVisitedAt: chatRoomPreviewData.lastVisitedAt), size: 50)
                }
                
                Spacer()
                    .frame(width: 10)
                
                NavigationLinkBorderless(destination: ChatRoomView(buddyId: chatRoomPreviewData.buddyId, buddyUsername: chatRoomPreviewData.buddyUsername)) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(chatRoomPreviewData.buddyUsername)
                                .lineLimit(1)
                            Spacer()
                            Text(sentAtDisplay(sentAt: global.chatData[chatRoomPreviewData.buddyId]!.messages.last!.sentAt))
                                .foregroundColor(.gray)
                        }
                        HStack {
                            if global.messageDrafts[chatRoomPreviewData.buddyId] != nil && global.messageDrafts[chatRoomPreviewData.buddyId] != "" {
                                Text("[Draft] \(global.messageDrafts[chatRoomPreviewData.buddyId]!.replacingOccurrences(of: "\n", with: " "))")
                                    .frame(height: 45, alignment: .top)
                                    .foregroundColor(.orange)
                                    .lineLimit(2)
                            } else {
                                Text(global.chatData[chatRoomPreviewData.buddyId]!.messages.last!.content.replacingOccurrences(of: "\n", with: " "))
                                    .frame(height: 45, alignment: .top)
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                            }
                            Spacer()
                            if getUnreadMessagesCounter() > 0 {
                                if getUnreadMessagesCounter() <= 99 {
                                    Text("\(getUnreadMessagesCounter())")
                                        .bold()
                                        .padding(10)
                                        .foregroundColor(.white)
                                        .background(Circle().fill(Color.red))
                                } else {
                                    Text("99+")
                                        .bold()
                                        .padding(10)
                                        .foregroundColor(.white)
                                        .background(Circle().fill(Color.red))
                                }
                            }
                        }
                    }
                    .background(Color.black.opacity(0.001)) // Expand button's tappable area to empty spaces.
                }
            }
        }
    }
    
    func sentAtDisplay(sentAt: Date) -> String {
        if Calendar.current.isDate(global.getUtcTime(), inSameDayAs: sentAt) {
            return sentAt.toLocal().toString(toFormat: "h:mm a")
        }
        if Calendar.current.isDate(global.getUtcTime().yesterday, inSameDayAs: sentAt) {
            return "Yesterday"
        }
        return sentAt.toLocal().toString(toFormat: "M/d/yy")
    }
    
    func getUnreadMessagesCounter() -> Int {
        var unreadCounter = 0
        for messageData in global.chatData[chatRoomPreviewData.buddyId]!.messages {
            if !messageData.isMine &&
                messageData.sentAt > global.chatData[chatRoomPreviewData.buddyId]!.lastMyReadAt {
                unreadCounter += 1
            }
        }
        return unreadCounter
    }
}

struct ChatRoomPreviewData: Identifiable, Codable {
    var id = UUID()
    var buddyId: String
    var buddyUsername: String
    var lastVisitedAt: Date

    init(buddyId: String,
         buddyUsername: String,
         lastVisitedAt: Date) {
        self.buddyId = buddyId
        self.buddyUsername = buddyUsername
        self.lastVisitedAt = lastVisitedAt
    }
}
