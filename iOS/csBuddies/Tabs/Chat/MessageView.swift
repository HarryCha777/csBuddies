//
//  MessageView.swift
//  csBuddies
//
//  Created by Harry Cha on 6/3/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct MessageView: View {
    @EnvironmentObject var global: Global
    
    let buddyId: String
    let messageData: MessageData
    
    @State private var showActionSheet = false
    
    var body: some View {
        if global.chatData[buddyId] != nil {
            HStack {
                if messageData.isMine {
                    Spacer()
                }
                
                HStack {
                    if !messageData.isMine {
                        VStack {
                            NavigationLinkBorderless(destination: UserView(userId: buddyId)) {
                                SmallImageView(userId: buddyId, isOnline: false, size: 35)
                            }
                            Spacer()
                        }
                    }
                    
                    Spacer()
                        .frame(width: 10)
                    
                    VStack(alignment: messageData.isMine ? .trailing: .leading, spacing: 0) {
                        HStack {
                            if messageData.isSending {
                                ActivityIndicatorView()
                            }

                            VStack(alignment: .leading) {
                                TruncatedText(text: messageData.content)
                                    .foregroundColor(.white)
                                    .onTapGesture { } // Prevent scrolling from being disabled due to onLongPressGesture.
                                    // onTapGesture(count: x) is disabled due to UITapGestureRecognizer in csBuddiesApp.
                                    .onLongPressGesture {
                                        showActionSheet = true
                                    }
                            }
                            .padding(8)
                            .background(messageData.isMine ? Color.green: Color.orange)
                            .cornerRadius(10)
                            .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Spacer()
                            .frame(height: 3)
                        
                        HStack {
                            if messageData.isMine &&
                                messageData.sentAt <= global.chatData[buddyId]!.lastBuddyReadAt {
                                Text("Read")
                                    .bold()
                                    .foregroundColor(.gray)
                            }
                            
                            Text(sentAtDisplay(sentAt: messageData.sentAt))
                                .foregroundColor(.gray)
                        }
                        
                        if messageData.isMine &&
                            !messageData.isSending &&
                            messageData.sentAt > global.chatData[buddyId]!.lastBuddyReadAt &&
                            messageData.sentAt == global.chatData[buddyId]!.messages.last!.sentAt {
                            Text("Delivered")
                                .bold()
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(5)
                
                if !messageData.isMine {
                    Spacer()
                }
            }
            .actionSheet(isPresented: $showActionSheet) {
                getActionSheet()
            }
        }
    }
    
    func sentAtDisplay(sentAt: Date) -> String {
        if Calendar.current.isDate(global.getUtcTime(), inSameDayAs: sentAt) {
            return sentAt.toLocal().toString(toFormat: "h:mm a")
        }
        if Calendar.current.isDate(global.getUtcTime().yesterday, inSameDayAs: sentAt) {
            return "Yesterday \(sentAt.toLocal().toString(toFormat: "h:mm a"))"
        }
        return sentAt.toLocal().toString(toFormat: "M/d/yy h:mm a")
    }
    
    func getActionSheet() -> ActionSheet {
        return ActionSheet(title: Text("Choose an Option"), buttons: [
            .default(Text("Copy")) {
                UIPasteboard.general.string = messageData.content
                
                global.confirmationText = "Copied"
            },
            .default(Text("Hide")) {
                let index = global.chatData[buddyId]!.messages.firstIndex(where: { $0.messageId == messageData.messageId })
                global.chatData[buddyId]?.messages.remove(at: index!)
            },
            .cancel()
        ])
    }
}

struct MessageData: Identifiable, Codable {
    var id = UUID()
    var messageId: String
    var isMine: Bool
    var isSending: Bool
    var sentAt: Date
    var content: String

    init(messageId: String,
         isMine: Bool,
         isSending: Bool,
         sentAt: Date,
         content: String) {
        self.messageId = messageId
        self.isMine = isMine
        self.isSending = isSending
        self.sentAt = sentAt
        self.content = content
    }
}
