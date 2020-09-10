//
//  SearchProfileLinkData.swift
//  csBuddies
//
//  Created by Harry Cha on 6/3/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct SearchProfileLinkData: Identifiable, Codable {
    var id: String
    var image: String
    var username: String
    var birthday: Date
    var genderIndex: Int
    var shortInterests: String
    var shortIntro: String
    var hasGitHub: Bool
    var hasLinkedIn: Bool

    init(id: String,
         image: String,
         username: String,
         birthday: Date,
         genderIndex: Int,
         shortInterests: String,
         shortIntro: String,
         hasGitHub: Bool,
         hasLinkedIn: Bool) {
        self.id = id
        self.image = image
        self.username = username
        self.birthday = birthday
        self.genderIndex = genderIndex
        self.shortInterests = shortInterests
        self.shortIntro = shortIntro
        self.hasGitHub = hasGitHub
        self.hasLinkedIn = hasLinkedIn
    }
}
