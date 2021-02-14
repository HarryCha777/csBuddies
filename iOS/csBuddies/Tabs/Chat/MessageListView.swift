//
//  MessageListView.swift
//  csBuddies
//
//  Created by Harry Cha on 6/16/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct MessageListView: View {
    @EnvironmentObject var global: Global
    @Environment(\.colorScheme) var colorScheme
    
    let buddyId: String
    let buddyUsername: String
    
    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            prepermission
    }

    var body: some View {
        if global.chatData[buddyId] != nil {
            List { // Use List instead of ScrollView since it displays more messages faster.
                if !global.hasAskedNotification {
                    HStack {
                        Spacer()
                        Text("Turn on Notification")
                            .foregroundColor(.blue)
                            .flip()
                            .onTapGesture { // Avoid using a Button since it highlights the entire row of the screen on press.
                                activeAlert = .prepermission
                            }
                        Spacer()
                    }
                }
                
                // Show messages in reverse order to flip them.
                ForEach(global.chatData[buddyId]!.messages.reversed()) { messageData in
                    MessageView(buddyId: buddyId, messageData: messageData)
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
            .alert(item: $activeAlert) { alert in
                switch alert {
                case .prepermission:
                    return Alert(title: Text("Get notified when \(buddyUsername) responds!"),
                          message: Text("Would you like to receive a notification when you receive text messages?"),
                          primaryButton: .destructive(Text("Not Now")),
                          secondaryButton: .default(Text("Notify Me"), action: {
                            global.askNotification()
                          }))
                }
            }
        }
    }
}
