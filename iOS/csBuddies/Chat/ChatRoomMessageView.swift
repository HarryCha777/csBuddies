//
//  ChatRoomMessageView.swift
//  FireBaseProject
//
//  Created by YOUNGSIC KIM on 2019-12-31.
//  Copyright © 2019 YOUNGSIC KIM. All rights reserved.
//

import SwiftUI

struct ChatRoomMessageView: View {
    @EnvironmentObject var global: Global
    
    let chatRoomMessageData: ChatRoomMessageData
    let messageContentLimit = 300
    
    @State private var mustVisitChatRoomMessageFullView = false
    
    var body: some View {
        HStack {
            if chatRoomMessageData.sender == self.global.username {
                Spacer()
            }
            
            VStack(alignment: (chatRoomMessageData.sender == global.username ? .trailing: .leading), spacing: 0) {
                Spacer()
                    .frame(height: 10)
            
                HStack {
                    if chatRoomMessageData.sender != global.username {
                        VStack {
                            SGNavigationLink(destination: SearchProfileView(buddyUsername: chatRoomMessageData.sender)) {
                                // Also check if buddyImageList[sender] is nil to temporarily deal with time it takes to fetch buddy's image the first time.
                                if self.global.buddyImageList[self.chatRoomMessageData.sender] == nil ||
                                    self.global.buddyImageList[self.chatRoomMessageData.sender] == "" {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .frame(width: 35, height: 35)
                                        .clipShape(Circle())
                                } else {
                                    Image(uiImage: self.global.buddyImageList[self.chatRoomMessageData.sender]!.toUiImage())
                                        .resizable()
                                        .frame(width: 35, height: 35)
                                        .clipShape(Circle())
                                }
                            }
                            Spacer()
                        }
                    }
                    
                    VStack(alignment: (chatRoomMessageData.sender == global.username ? .trailing: .leading)) {
                        HStack {
                            VStack(alignment: .trailing) {
                                Spacer()
                                if chatRoomMessageData.sender == global.username {
                                    if chatRoomMessageData.isRead {
                                        Text("Read")
                                            .foregroundColor(Color.gray)
                                    } else if chatRoomMessageData.isDeleted {
                                        Text("Left Chat")
                                            .foregroundColor(Color.red)
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading) {
                                if chatRoomMessageData.content.count <= messageContentLimit {
                                    Text(chatRoomMessageData.content)
                                        .foregroundColor(Color.white)
                                } else {
                                    Text(chatRoomMessageData.content[0...messageContentLimit])
                                        .foregroundColor(Color.white)
                                    Text("More")
                                        .foregroundColor(Color.blue)
                                        .onTapGesture {
                                            self.mustVisitChatRoomMessageFullView = true
                                        }
                                    
                                    // Make invisible view to handle navigation to Chat Room Message Full View when needed.
                                    if mustVisitChatRoomMessageFullView {
                                        NavigationLink(destination: ChatRoomMessageFullView(messageContent: chatRoomMessageData.content),
                                                       isActive: $mustVisitChatRoomMessageFullView) {
                                                        EmptyView()
                                        }
                                    }
                                }
                            }
                            .padding(8)
                            .background(chatRoomMessageData.sender == global.username ? Color.green: Color.orange)
                            .cornerRadius(10)
                            .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Text(displaySentTime(sentTime: chatRoomMessageData.sentTime))
                            .foregroundColor(Color.gray)
                    }
                }
            }

            if chatRoomMessageData.sender != self.global.username {
                Spacer()
            }
        }
    }
    
    func displaySentTime(sentTime: Date) -> String {
        let date = sentTime
        let formatter = DateFormatter()
        if Calendar.current.isDate(global.getUtcTime(), inSameDayAs: sentTime) {
            formatter.dateFormat = "h:mm a"
        } else {
            formatter.dateFormat = "M/d/yy h:mm a"
        }
        return formatter.string(from: date)
    }
}

struct ChatRoomMessageView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomMessageView(chatRoomMessageData: ChatRoomMessageData(
            id: "id1",
            sender: "sender",
            receiver: "receiver",
            sentTime: Date(),
            content: "content1",
            isRead: false,
            isDeleted: false))
            .previewLayout(PreviewLayout.fixed(width: 500, height: 140))
    }
}
