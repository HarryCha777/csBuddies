//
//  ChatRoomMessageView.swift
//  csBuddies
//
//  Created by Harry Cha on 6/3/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct ChatRoomMessageView: View {
    @EnvironmentObject var global: Global
    
    let buddyId: String
    let chatRoomMessageData: ChatRoomMessageData
    
    @State private var hasExpanded = false
    @State private var hasTruncated = false
    @State private var showActionSheet = false
    
    var body: some View {
        VStack {
            if global.chatData[buddyId] != nil {
                HStack {
                    if chatRoomMessageData.isMine {
                        Spacer()
                    }
                    
                    VStack(alignment: (chatRoomMessageData.isMine ? .trailing: .leading), spacing: 0) {
                        Spacer()
                            .frame(height: 10)
                        
                        HStack {
                            if !chatRoomMessageData.isMine {
                                VStack {
                                    NavigationLinkBorderless(destination: BuddiesProfileView(buddyId: buddyId)) {
                                        SmallImageView(userId: buddyId, isOnline: false, size: 35, myImage: global.smallImage)
                                    }
                                    Spacer()
                                }
                            }
                            
                            Spacer()
                                .frame(width: 10)
                            
                            VStack(alignment: chatRoomMessageData.isMine ? .trailing: .leading, spacing: 0) {
                                VStack(alignment: .leading) {
                                    //Text(chatRoomMessageData.content)
                                    TruncatedText(text: chatRoomMessageData.content, hasExpanded: $hasExpanded, hasTruncated: $hasTruncated)
                                        .foregroundColor(Color.white)
                                        .onTapGesture { } // Prevent scrolling from being disabled due to onLongPressGesture.
                                        // onTapGesture(count: x) is disabled due to UITapGestureRecognizer in csBuddiesApp.
                                        .onLongPressGesture {
                                            showActionSheet = true
                                        }
                                }
                                .padding(8)
                                .background(chatRoomMessageData.isMine ? Color.green: Color.orange)
                                .cornerRadius(10)
                                .fixedSize(horizontal: false, vertical: true)
                                
                                HStack {
                                    if chatRoomMessageData.isMine &&
                                        chatRoomMessageData.sendTime <= global.chatData[buddyId]!.lastBuddyReadTime {
                                        Text("Read")
                                            .bold()
                                            .foregroundColor(Color.gray)
                                    }
                                    
                                    Text(sendTimeDisplay(sendTime: chatRoomMessageData.sendTime))
                                        .foregroundColor(Color.gray)
                                }
                                
                                if chatRoomMessageData.isMine &&
                                    chatRoomMessageData.sendTime > global.chatData[buddyId]!.lastBuddyReadTime &&
                                    chatRoomMessageData.sendTime == global.chatData[buddyId]!.messages.last!.sendTime {
                                    Text("Delivered")
                                        .bold()
                                        .foregroundColor(Color.gray)
                                }
                            }
                        }
                    }
                    
                    if !chatRoomMessageData.isMine {
                        Spacer()
                    }
                }
            }
        }
        .actionSheet(isPresented: $showActionSheet) {
            getActionSheet()
        }
    }
    
    func sendTimeDisplay(sendTime: Date) -> String {
        if Calendar.current.isDate(global.getUtcTime(), inSameDayAs: sendTime) {
            return sendTime.toLocal().toString(toFormat: "h:mm a")
        }
        if Calendar.current.isDate(global.getUtcTime().yesterday, inSameDayAs: sendTime) {
            return "Yesterday \(sendTime.toLocal().toString(toFormat: "h:mm a"))"
        }
        return sendTime.toLocal().toString(toFormat: "M/d/yy h:mm a")
    }
    
    func getActionSheet() -> ActionSheet {
        return ActionSheet(title: Text("Choose an Option"), buttons: [
            .default(Text("Copy")) {
                UIPasteboard.general.string = chatRoomMessageData.content
                
                global.confirmationText = "Copied"
            },
            .default(Text("Hide")) {
                let index = global.chatData[buddyId]!.messages.firstIndex(where: { $0.messageId == chatRoomMessageData.messageId })
                global.chatData[buddyId]?.messages.remove(at: index!)
                if global.chatData[buddyId]!.messages.count == 0 {
                    global.chatData[buddyId] = nil
                }
                
                global.confirmationText = "Hidden"
            },
            .cancel()
        ])
    }
}

struct ChatRoomMessageData: Identifiable, Codable {
    var id = UUID()
    var messageId: String
    var isMine: Bool
    var sendTime: Date
    var content: String

    init(messageId: String,
         isMine: Bool,
         sendTime: Date,
         content: String) {
        self.messageId = messageId
        self.isMine = isMine
        self.sendTime = sendTime
        self.content = content
    }
}
