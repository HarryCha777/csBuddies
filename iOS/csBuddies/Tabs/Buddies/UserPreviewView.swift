//
//  UserPreviewView.swift
//  csBuddies
//
//  Created by Harry Cha on 6/3/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct UserPreviewView: View {
    @EnvironmentObject var global: Global
    @Environment(\.colorScheme) var colorScheme
    
    let userId: String
    // global.users[userId] must be set in advance.
    
    @State private var showActionSheet = false
    
    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            joinToBlock,
            joinToReport,
            block
    }
    
    @State var activeSheet: Sheets?
    enum Sheets: Identifiable {
        var id: Int { self.hashValue }
        case
            buddiesProfileReport
    }
    
    var body: some View {
        NavigationLinkNoArrow(destination: UserView(userId: userId)) {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    SmallImageView(userId: userId, isOnline: global.isOnline(lastVisitedAt: global.userPreviews[userId]!.lastVisitedAt), size: 75)

                    Spacer()
                        .frame(width: 10)

                    VStack(alignment: .leading) {
                        Text(global.userPreviews[userId]!.username)
                            .bold()
                            .lineLimit(1)
                        HStack {
                            if global.userPreviews[userId]!.gender == 0 {
                                Text(global.genderOptions[global.userPreviews[userId]!.gender])
                                    .font(.footnote)
                                    .foregroundColor(.blue) +
                                    Text(",")
                                    .font(.footnote)
                            } else if global.userPreviews[userId]!.gender == 1 {
                                Text(global.genderOptions[global.userPreviews[userId]!.gender])
                                    .font(.footnote)
                                    .foregroundColor(Color(red: 255 / 255, green: 20 / 255, blue: 147 / 255)) + // This is pink 
                                    Text(",")
                                    .font(.footnote)
                            } else if global.userPreviews[userId]!.gender == 2 ||
                                        global.userPreviews[userId]!.gender == 3 {
                                Text(global.genderOptions[global.userPreviews[userId]!.gender])
                                    .font(.footnote)
                                    .foregroundColor(.gray) +
                                    Text(",")
                                    .font(.footnote)
                            } else {
                                Text("Unknown")
                                    .font(.footnote) +
                                    Text(",")
                                    .font(.footnote)
                            }
                            Text(global.userPreviews[userId]!.birthday.toString()[0] != "0" ? "\(global.userPreviews[userId]!.birthday.toAge())" : "N/A")
                                .font(.footnote)
                        }
                        Text(global.countryOptions[safe: global.userPreviews[userId]!.country] ?? "Unknown")
                            .font(.footnote)
                        if global.isOnline(lastVisitedAt: global.userPreviews[userId]!.lastVisitedAt) {
                            Text("Online now")
                                .foregroundColor(.green)
                                .font(.footnote)
                        } else {
                            Text("Online \(Calendar.current.date(byAdding: .second, value: global.onlineTimeout, to: global.userPreviews[userId]!.lastVisitedAt)!.toTimeDifference(hasExtension: true))")
                                .foregroundColor(.gray)
                                .font(.footnote)
                        }
                    }
                    
                    Spacer()
                    
                    if global.myId != userId {
                        Button(action: {
                            showActionSheet = true
                        }) {
                            Image(systemName: "ellipsis")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .buttonStyle(BorderlessButtonStyle()) // Prevent button from being triggered when anywhere on view is clicked.
                    }
                }
                
                TruncatedText(text: global.userPreviews[userId]!.intro)
                    .frame(maxWidth: .infinity, alignment: .leading) // Prevent any extra paddings.
                
                // Unlike comment reply buttons, do not have a button to directly message the user except in UserProfileView
                // because the user must view the full context, including the user's interests, social media, and content, before messaging.
            }
            .padding(.vertical)
        }
        .actionSheet(isPresented: $showActionSheet) {
            getActionSheet()
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .buddiesProfileReport:
                NavigationView {
                    ReportView(buddyId: userId)
                        .environmentObject(globalObject)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .joinToBlock:
                return Alert(title: Text("Join us to block \(global.userPreviews[userId]!.username)."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Join"), action: {
                    global.activeRootView = .join
                }))
            case .joinToReport:
                return Alert(title: Text("Join us to report \(global.userPreviews[userId]!.username)."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Join"), action: {
                    global.activeRootView = .join
                }))
            case .block:
                return Alert(title: Text("Block Buddy"), message: Text("Their profiles, bytes, and comments will be hidden, and you will no longer receive messages or notifications from them. They will never know that you blocked them."), primaryButton: .default(Text("Cancel")), secondaryButton: .destructive(Text("Block"), action: {
                    global.block(buddyId: userId)
                }))
            }
        }
    }
    
    func getActionSheet() -> ActionSheet {
        var buttons = [Alert.Button]()
        
        if !global.blockedBuddyIds.contains(userId) {
            buttons += [Alert.Button.destructive(Text("Block")) {
                if global.myId == "" {
                    activeAlert = .joinToBlock
                } else {
                    activeAlert = .block
                }
            }]
        } else {
            buttons += [Alert.Button.default(Text("Unblock")) {
                global.unblock(buddyId: userId)
            }]
        }
        
        buttons += [Alert.Button.destructive(Text("Report")) {
            if global.myId == "" {
                activeAlert = .joinToReport
            } else {
                activeSheet = .buddiesProfileReport
            }
        }]
        
        return ActionSheet(title: Text("Select an option"),
                           buttons: buttons + [Alert.Button.cancel()])
    }
}

struct UserPreviewData: Identifiable, Codable {
    var id = UUID()
    var userId: String
    var username: String
    var gender: Int
    var birthday: Date
    var country: Int
    var intro: String
    var lastVisitedAt: Date

    init(userId: String,
         username: String,
         gender: Int,
         birthday: Date,
         country: Int,
         intro: String,
         lastVisitedAt: Date) {
        self.userId = userId
        self.username = username
        self.gender = gender
        self.birthday = birthday
        self.country = country
        self.intro = intro
        self.lastVisitedAt = lastVisitedAt
    }
    
    func updateClientData() {
        globalObject.userPreviews[userId] = self
        
        if globalObject.inboxData.notifications.contains(where: { $0.buddyId == userId }) {
            let index = globalObject.inboxData.notifications.firstIndex(where: { $0.buddyId == userId })
            globalObject.inboxData.notifications[index!].buddyUsername = username
        }
        
        if globalObject.chatData.contains(where: { $0.key == userId }) &&
            globalObject.chatData[userId]!.username != username {
            globalObject.chatData[userId]!.username = username
        }
    }
}
