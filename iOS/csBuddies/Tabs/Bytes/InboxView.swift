//
//  InboxView.swift
//  csBuddies
//
//  Created by Harry Cha on 1/21/21.
//  Copyright © 2021 Harry Cha. All rights reserved.
//

import SwiftUI

struct InboxView: View {
    @EnvironmentObject var global: Global
    
    var body: some View {
        List {
            ForEach(global.inboxData.notifications.reversed()) { notificationData in
                NotificationView(notificationData: notificationData)
            }
            .onDelete(perform: deleteInboxNotification)
            // Do not use .id(UUID()) to prevent the app from freezing for an unknown reason.

            if global.inboxData.notifications.count == 0 {
                Text("Your Inbox is empty.")
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Inbox", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                EditButton()
            }
        }
        .onAppear {
            markAllRead()
        }
        .onDisappear {
            markAllRead()
        }
    }
    
    func deleteInboxNotification(at offsets: IndexSet) {
        let index = global.inboxData.notifications.count - 1 - offsets.first! // Reverse index since array is reversed.
        global.inboxData.notifications.remove(at: index)
    }
    
    func markAllRead() {
        if global.getUnreadNotificationsCounter() > 0 {
            global.inboxData.lastReadAt = global.getUtcTime()
            global.updateBadges()
        }
    }
}

struct InboxData: Identifiable, Codable {
    var id = UUID()
    var notifications = [NotificationData]()
    var lastReadAt = Date(timeIntervalSince1970: 0)
}
