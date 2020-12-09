//
//  UserRowView.swift
//  csBuddies
//
//  Created by Harry Cha on 11/6/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct UserRowView: View {
    @EnvironmentObject var global: Global
    
    let userRowData: UserRowData

    var body: some View {
        HStack {
            SmallImageView(userId: userRowData.userId, isOnline: userRowData.isOnline, size: 35, myImage: global.smallImage)
            Text(userRowData.username)
                .lineLimit(1)
            Spacer()
            Text(userRowData.appendTime.toTimeDifference())
        }
        .background(Color.black.opacity(0.001)) // Expand button's tappable area to empty spaces.
    }
}

struct UserRowData: Identifiable, Codable {
    var id = UUID()
    var userId: String
    var username: String
    var isOnline: Bool
    var appendTime: Date

    init(userId: String,
         username: String,
         isOnline: Bool,
         appendTime: Date) {
        self.userId = userId
        self.username = username
        self.isOnline = isOnline
        self.appendTime = appendTime
    }
}
