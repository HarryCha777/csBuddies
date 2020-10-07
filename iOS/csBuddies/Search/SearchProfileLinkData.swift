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
    var intro: String
    var hasGitHub: Bool
    var hasLinkedIn: Bool

    init(id: String,
         image: String,
         username: String,
         birthday: Date,
         genderIndex: Int,
         intro: String,
         hasGitHub: Bool,
         hasLinkedIn: Bool) {
        self.id = id
        self.image = image
        self.username = username
        self.birthday = birthday
        self.genderIndex = genderIndex
        self.intro = intro
        self.hasGitHub = hasGitHub
        self.hasLinkedIn = hasLinkedIn
    }
}
