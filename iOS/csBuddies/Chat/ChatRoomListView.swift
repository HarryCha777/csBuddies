//
//  ChatRoomListView.swift
//  csBuddies
//
//  Created by Harry Cha on 6/16/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct ChatRoomListView: View {
    @EnvironmentObject var global: Global
    @Environment(\.colorScheme) var colorScheme
    
    let buddyUsername: String
    
    @State private var showActions = false
    @State private var selectedMessageContent = ""
    @State private var selectedMessageId = ""

    var body: some View {
        VStack {
            if global.chatHistory[buddyUsername] != nil {
                List { // use list instead of scroll view since it displays more messages faster
                    // Show messages in reverse order to flip them.
                    ForEach(self.global.chatHistory[self.buddyUsername]!.reversed()) { chatRoomMessageData in
                        ChatRoomMessageView(chatRoomMessageData: chatRoomMessageData)
                            .padding(.horizontal)
                            .onTapGesture(count: 2) {
                                // Get content and ID now since they are inaccessible in action sheet.
                                self.selectedMessageContent = chatRoomMessageData.content
                                self.selectedMessageId = chatRoomMessageData.id
                                self.showActions = true
                            }
                            .onLongPressGesture {
                                // Get content and ID now since they are inaccessible in action sheet.
                                self.selectedMessageContent = chatRoomMessageData.content
                                self.selectedMessageId = chatRoomMessageData.id
                                self.showActions = true
                            }
                            .actionSheet(isPresented: self.$showActions) {
                                ActionSheet(title: Text("Choose an Option"), buttons: [
                                    .default(Text("Copy")) {
                                        UIPasteboard.general.string = self.selectedMessageContent
                                    },
                                    .default(Text("Hide")) {
                                        let index = self.global.chatHistory[self.buddyUsername]!.firstIndex(where: { $0.id == self.selectedMessageId })
                                        self.global.chatHistory[self.buddyUsername]?.remove(at: index!)
                                        if self.global.chatHistory[self.buddyUsername]!.count == 0 {
                                            self.global.chatHistory[self.buddyUsername] = nil
                                        }
                                    },
                                    .cancel()
                                ])
                            }
                            .flip()
                    }
                    .listRowBackground(colorScheme == .light ? Color.white : Color.black) // set message background
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0)) // remove space in-between messages
                }
                .flip()
                .listStyle(PlainListStyle()) // remove extra space on top and bottom
                .introspectTableView { tableView in // change tableView only for this view
                    tableView.separatorStyle = .none // remove line separators
                    tableView.backgroundColor = self.colorScheme == .light ? UIColor.white : UIColor.black // set list background
                }
            }
        }
    }
}

struct ChatRoomListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomListView(buddyUsername: "")
    }
}
