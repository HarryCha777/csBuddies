//
//  NotificationView.swift
//  csBuddies
//
//  Created by Harry Cha on 1/23/21.
//  Copyright © 2021 Harry Cha. All rights reserved.
//

import SwiftUI

struct NotificationView: View {
    @EnvironmentObject var global: Global
    
    let notificationData: NotificationData
    
    @State private var showActionSheet = false
    
    var body: some View {
        HStack {
            NavigationLinkBorderless(destination: UserView(userId: notificationData.buddyId)) {
                VStack {
                    SmallImageView(userId: notificationData.buddyId, isOnline: global.isOnline(lastVisitedAt: notificationData.lastVisitedAt), size: 50)
                    Spacer()
                }
            }
            
            Spacer()
                .frame(width: 10)
            
            NavigationLinkBorderless(destination: ByteView(byteId: notificationData.byteId)) {
                VStack(alignment: .leading) {
                    HStack {
                        switch notificationData.type {
                        case 0:
                            Text("\(notificationData.buddyUsername) liked your byte.")
                        case 1:
                            Text("\(notificationData.buddyUsername) liked your comment.")
                        case 2:
                            Text("\(notificationData.buddyUsername) commented on your byte.")
                        case 3:
                            Text("\(notificationData.buddyUsername) replied to your comment.")
                        default:
                            EmptyView()
                        }
                        Spacer()
                        Text(notificationData.notifiedAt.toTimeDifference())
                            .foregroundColor(.gray)
                    }
                    TruncatedText(text: notificationData.content)
                        .foregroundColor(.gray)
                }
                .background(Color.black.opacity(0.001)) // Expand button's tappable area to empty spaces.
            }
        }
    }
}

struct NotificationData: Identifiable, Codable {
    var id = UUID()
    var notificationId: String
    var byteId: String
    var buddyId: String
    var buddyUsername: String
    var lastVisitedAt: Date
    var content: String
    var type: Int
    var notifiedAt: Date

    init(notificationId: String,
         byteId: String,
         buddyId: String,
         buddyUsername: String,
         lastVisitedAt: Date,
         content: String,
         type: Int,
         notifiedAt: Date) {
        self.notificationId = notificationId
        self.byteId = byteId
        self.buddyId = buddyId
        self.buddyUsername = buddyUsername
        self.lastVisitedAt = lastVisitedAt
        self.content = content
        self.type = type
        self.notifiedAt = notifiedAt
    }
}
