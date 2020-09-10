//
//  ChatRoomMessageData.swift
//  csBuddies
//
//  Created by Harry Cha on 6/3/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct ChatRoomMessageData: Identifiable, Codable {
    var id: String
    var sender: String
    var receiver: String
    var sentTime: Date
    var content: String
    var isRead: Bool
    var isDeleted: Bool

    init(id: String,
         sender: String,
         receiver: String,
         sentTime: Date,
         content: String,
         isRead: Bool,
         isDeleted: Bool) {
        self.id = id
        self.sender = sender
        self.receiver = receiver
        self.sentTime = sentTime
        self.content = content
        self.isRead = isRead
        self.isDeleted = isDeleted
    }
}
