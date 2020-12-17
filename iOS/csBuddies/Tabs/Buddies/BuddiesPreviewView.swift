//
//  BuddiesPreviewView.swift
//  csBuddies
//
//  Created by Harry Cha on 6/3/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct BuddiesPreviewView: View {
    @EnvironmentObject var global: Global
    @Environment(\.colorScheme) var colorScheme
    
    let userPreviewData: UserPreviewData
    let myImage: String
    
    @State private var hasExpanded = false
    @State private var hasTruncated = false
    
    var body: some View {
        NavigationLinkNoArrow(destination: BuddiesProfileView(buddyId: userPreviewData.userId)) {
            VStack {
                HStack {
                    SmallImageView(userId: userPreviewData.userId, isOnline: userPreviewData.isOnline, size: 75, myImage: myImage)

                    Spacer()
                        .frame(width: 20)

                    // Set spacing to 0 to preveng GitHub and LinkedIn logos from taking unnecessary vertical space.
                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            if userPreviewData.isOnline {
                                HStack {
                                    Circle()
                                        .frame(width: 8, height: 8)
                                        .foregroundColor(Color.white)
                                    Text("Online")
                                        .foregroundColor(Color.white)
                                }
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.green)
                                .cornerRadius(5)
                            } else {
                                Text(Calendar.current.date(byAdding: .second, value: global.onlineTimeout, to: userPreviewData.lastVisitTime)!.toTimeDifference())
                            }
                        }
                        
                        HStack {
                            Text(userPreviewData.username)
                                .bold()
                                .lineLimit(1)
                            Spacer()
                        }
                        
                        HStack {
                            if userPreviewData.genderIndex == 0 {
                                Text(global.genderOptions[userPreviewData.genderIndex])
                                    .foregroundColor(Color.blue) +
                                    Text(",")
                            } else if userPreviewData.genderIndex == 1 {
                                Text(global.genderOptions[userPreviewData.genderIndex])
                                    .foregroundColor(Color(red: 255 / 255, green: 20 / 255, blue: 147 / 255)) + // This is pink color.
                                    Text(",")
                            } else if userPreviewData.genderIndex == 2 ||
                                        userPreviewData.genderIndex == 3 {
                                Text(global.genderOptions[userPreviewData.genderIndex])
                                    .foregroundColor(Color.gray) +
                                    Text(",")
                            } else {
                                Text("Unknown") +
                                    Text(",")
                            }
                            Text(userPreviewData.birthday.toString()[0] != "0" ? "\(userPreviewData.birthday.toAge())" : "N/A")
                            Spacer()
                            if userPreviewData.hasGitHub {
                                Image("gitHubLogo")
                                    .resizable()
                                    .frame(width: 22, height: 22)
                                    .if(colorScheme == .dark) { content in
                                        content.colorInvert() // Invert color on dark mode.
                                    }
                            }
                            if userPreviewData.hasLinkedIn {
                                Image("linkedInLogo")
                                    .resizable()
                                    .frame(width: 22, height: 22)
                            }
                        }
                    }
                }
                
                TruncatedText(text: userPreviewData.intro, hasExpanded: $hasExpanded, hasTruncated: $hasTruncated)
                    .frame(maxWidth: .infinity, alignment: .leading) // Prevent any extra paddings.
            }
            .padding(.vertical)
        }
        .disabled(global.myId == userPreviewData.userId)
    }
}

struct UserPreviewData: Identifiable, Codable {
    var id = UUID()
    var userId: String
    var username: String
    var birthday: Date
    var genderIndex: Int
    var intro: String
    var hasGitHub: Bool
    var hasLinkedIn: Bool
    var isOnline: Bool
    var lastVisitTime: Date

    init(userId: String,
         username: String,
         birthday: Date,
         genderIndex: Int,
         intro: String,
         hasGitHub: Bool,
         hasLinkedIn: Bool,
         isOnline: Bool,
         lastVisitTime: Date) {
        self.userId = userId
        self.username = username
        self.birthday = birthday
        self.genderIndex = genderIndex
        self.intro = intro
        self.hasGitHub = hasGitHub
        self.hasLinkedIn = hasLinkedIn
        self.isOnline = isOnline
        self.lastVisitTime = lastVisitTime
    }
}
