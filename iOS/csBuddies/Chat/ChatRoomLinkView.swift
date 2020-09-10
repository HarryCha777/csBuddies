//
//  ChatRoomLinkView.swift
//  csBuddies
//
//  Created by Harry Cha on 6/6/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct ChatRoomLinkView: View {
    @EnvironmentObject var global: Global

    let buddyUsername: String

    var body: some View {
        VStack {
            if global.chatHistory[buddyUsername] == nil {
                EmptyView()
            } else {
                HStack {
                    SGNavigationLink(destination: SearchProfileView(buddyUsername: buddyUsername)) {
                        if self.global.buddyImageList[self.buddyUsername] == "" {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        } else {
                            Image(uiImage: self.global.buddyImageList[self.buddyUsername]!.toUiImage())
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        }
                    }
                    
                    Spacer()
                        .frame(width: 20)
                    
                    SGNavigationLink(destination: ChatRoomView(buddyUsername: buddyUsername)) {
                        HStack {
                            VStack(alignment: .leading) {
                                HStack {
                                Text(self.buddyUsername)
                                    .lineLimit(1)
                                }
                                HStack {
                                Text("\(self.getLastMessage())")
                                    .foregroundColor(Color.gray)
                                    .lineLimit(1)
                                }
                            }
                            
                            Spacer()
                            
                            if self.getUnreadCounter() > 0 {
                                if self.getUnreadCounter() <= 99 {
                                    Text("\(self.getUnreadCounter())")
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
                        // Place (almost) invisible rectangle in background regardless of light or dark mode.
                        // This is so that this navigation link executes even when user clicked on an empty space.
                        .background(Rectangle().fill(Color.black.opacity(0.0001)))
                    }
                }
            }
        }
    }
    
    func getLastMessage() -> String {
        return global.chatHistory[buddyUsername]!.last!.content
    }
    
    func getUnreadCounter() -> Int {
        var unreadCounter = 0
        for chatRoomMessageData in global.chatHistory[buddyUsername]! {
            if chatRoomMessageData.sender != global.username &&
                !chatRoomMessageData.isRead {
                unreadCounter += 1
            }
        }
        return unreadCounter
    }
}

struct ChatRoomLinkView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomLinkView(buddyUsername: "")
            .environmentObject(Global())
    }
}
