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
    
    let buddyId: String

    var body: some View {
        VStack {
            if global.chatData[buddyId] != nil {
                List { // Use List instead of ScrollView since it displays more messages faster.
                    // Show messages in reverse order to flip them.
                    ForEach(global.chatData[buddyId]!.messages.reversed()) { chatRoomMessageData in
                        ChatRoomMessageView(buddyId: buddyId, chatRoomMessageData: chatRoomMessageData)
                            .padding(.horizontal)
                            .flip()
                    }
                    .listRowBackground(colorScheme == .light ? Color.white : Color.black) // Set message's background.
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0)) // Remove space in-between messages.
                }
                .flip()
                .removeLineSeparators()
                .introspectTableView { tableView in // Change tableView only for this view.
                    tableView.backgroundColor = colorScheme == .light ? UIColor.white : UIColor.black // Set List's background.
                }
            }
        }
    }
}
