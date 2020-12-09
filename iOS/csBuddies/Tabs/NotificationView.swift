//
//  NotificationView.swift
//  csBuddies
//
//  Created by Harry Cha on 11/5/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct NotificationView: View {
    @EnvironmentObject var global: Global
    
    @State private var mustVisitChatRoom = false
    @State private var mustVisitBuddiesProfile = false

    var body: some View {
        if global.hasClickedNotification {
            if global.notificationType == "chat" {
                Spacer()
                    .onAppear {
                        mustVisitChatRoom = true
                        global.hasClickedNotification = false
                    }
            } else if global.notificationType == "byte" {
                Spacer()
                    .onAppear {
                        mustVisitBuddiesProfile = true
                        global.hasClickedNotification = false
                    }
            }
        }
        
        // Must pass environment object or app may crash if it is opened via the notification click.
        NavigationLinkEmpty(destination: ChatRoomView(buddyId: global.notificationBuddyId, buddyUsername: global.notificationBuddyUsername).environmentObject(globalObject), isActive: $mustVisitChatRoom)

        // Must pass environment object or app may crash if it is opened via the notification click.
        NavigationLinkEmpty(destination: BuddiesProfileView(buddyId: global.notificationBuddyId).environmentObject(globalObject), isActive: $mustVisitBuddiesProfile)
    }
}
