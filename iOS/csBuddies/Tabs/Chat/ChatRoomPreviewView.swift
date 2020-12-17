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

    let buddyId: String
    let buddyUsername: String
    let isOnline: Bool
    
    var body: some View {
        // Check messages.last != nil instead of messages.count > 0 since latter may crash when chat rooms are deleted.
        if global.chatData[buddyId] != nil && global.chatData[buddyId]!.messages.last != nil {
            HStack {
                NavigationLinkBorderless(destination: BuddiesProfileView(buddyId: buddyId)) {
                    SmallImageView(userId: buddyId, isOnline: isOnline, size: 50, myImage: global.smallImage)
                }
                
                Spacer()
                    .frame(width: 10)
                
                NavigationLinkBorderless(destination: ChatRoomView(buddyId: buddyId, buddyUsername: buddyUsername)) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(buddyUsername)
                                .lineLimit(1)
                            Spacer()
                            Text(sendTimeDisplay(sendTime: global.chatData[buddyId]!.messages.last!.sendTime))
                                .foregroundColor(Color.gray)
                        }
                        HStack {
                            if global.messageDrafts[buddyId] != nil && global.messageDrafts[buddyId] != "" {
                                Text("[Draft] \(global.messageDrafts[buddyId]!.replacingOccurrences(of: "\n", with: " "))")
                                    .frame(height: 45, alignment: .top)
                                    .foregroundColor(Color.orange)
                                    .lineLimit(2)
                            } else {
                                Text(global.chatData[buddyId]!.messages.last!.content.replacingOccurrences(of: "\n", with: " "))
                                    .frame(height: 45, alignment: .top)
                                    .foregroundColor(Color.gray)
                                    .lineLimit(2)
                            }
                            Spacer()
                            if getUnreadCounter() > 0 {
                                if getUnreadCounter() <= 99 {
                                    Text("\(getUnreadCounter())")
                                        .bold()
                                        .padding(10)
                                        .foregroundColor(Color.white)
                                        .background(Circle().fill(Color.blue))
                                } else {
                                    Text("99+")
                                        .bold()
                                        .padding(10)
                                        .foregroundColor(Color.white)
                                        .background(Circle().fill(Color.blue))
                                }
                            }
                        }
                    }
                    .background(Color.black.opacity(0.001)) // Expand button's tappable area to empty spaces.
                }
            }
        }
    }
    
    
    func sendTimeDisplay(sendTime: Date) -> String {
        if Calendar.current.isDate(global.getUtcTime(), inSameDayAs: sendTime) {
            return sendTime.toLocal().toString(toFormat: "h:mm a")
        }
        if Calendar.current.isDate(global.getUtcTime().yesterday, inSameDayAs: sendTime) {
            return "Yesterday"
        }
        return sendTime.toLocal().toString(toFormat: "M/d/yy")
    }
    
    func getUnreadCounter() -> Int {
        var unreadCounter = 0
        for chatRoomMessageData in global.chatData[buddyId]!.messages {
            if !chatRoomMessageData.isMine &&
                chatRoomMessageData.sendTime > global.chatData[buddyId]!.lastMyReadTime {
                unreadCounter += 1
            }
        }
        return unreadCounter
    }
}
