//
//  ChatRoomView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/28/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase

struct ChatRoomView: View {
    @EnvironmentObject var global: Global
    @Environment(\.presentationMode) var presentation
    
    let buddyId: String
    let buddyUsername: String

    @State private var showActionSheet = false
    @State private var mustVisitBuddiesProfile = false

    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            block,
            clear
    }

    @State var activeSheet: Sheets?
    enum Sheets: Identifiable {
        var id: Int { self.hashValue }
        case
            buddiesProfileReport
    }

    var body: some View {
        ZStack {
            VStack {
                MessageListView(buddyId: buddyId, buddyUsername: buddyUsername)
                Spacer()
                MessageInputView(buddyId: buddyId, buddyUsername: buddyUsername, message: global.messageDrafts[buddyId] ?? "")
                    .environmentObject(globalObject)
            }
            .navigationBarTitle(buddyUsername, displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack { // Having at least 2 views inside HStack is necessary to make Image larger.
                        Spacer()
                        Button(action: {
                            showActionSheet = true
                        }) {
                            Image(systemName: "ellipsis")
                                .font(.largeTitle)
                        }
                    }
                }
            }
            
            NavigationLinkEmpty(destination: UserView(userId: buddyId), isActive: $mustVisitBuddiesProfile)
        }
        .actionSheet(isPresented: $showActionSheet) {
            getActionSheet()
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .buddiesProfileReport:
                NavigationView {
                    ReportView(buddyId: buddyId)
                        .environmentObject(globalObject)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
        .overlay(
            // Place alert here since MessageInputView's alerts are disabled if alerts are modified to the view wrapping it.
            Spacer()
                .alert(item: $activeAlert) { alert in
                    switch alert {
                    case .block:
                        return Alert(title: Text("Block Buddy"), message: Text("Their profiles, bytes, and comments will be hidden, and you will no longer receive messages or notifications from them. They will never know that you blocked them."), primaryButton: .default(Text("Cancel")), secondaryButton: .destructive(Text("Block"), action: {
                            // Create userPreviewData with only the available information and leave it to be updated later.
                            let userPreviewData = UserPreviewData(
                                userId: buddyId,
                                username: buddyUsername,
                                birthday: global.getUtcTime(),
                                genderIndex: 3,
                                countryIndex: 0,
                                intro: "",
                                lastVisitedAt: Date(timeIntervalSince1970: 0))
                            userPreviewData.updateClientData()
                            global.block(buddyId: buddyId)
                        }))
                    case .clear:
                        return Alert(title: Text("Are you sure?"), message: Text("You cannot undo this action."), primaryButton: .default(Text("Cancel")
                        ), secondaryButton: .destructive(Text("Clear"), action: {
                            global.chatData[buddyId] = nil
                            global.updateBadges()
                            
                            presentation.wrappedValue.dismiss()
                            global.confirmationText = "Cleared"
                        }))
                    }
                }
        )
        .onAppear {
            // The onDisappear of previous view is called later than onAppear of new view,
            // which will result in blank chatBuddyId if user navigates between 2 ChatRoomViews using tabs,
            // so have a short delay. Sometimes, delay of 0.1 seconds is not enough.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                global.chatBuddyId = buddyId
                global.chatBuddyUsername = buddyUsername
                markAllRead()
            }
        }
        .onDisappear {
            global.chatBuddyId = ""
            global.chatBuddyUsername = ""
            markAllRead()
        }
    }
    
    func markAllRead() {
        var mustUpdateBadges = false
        if global.chatData[buddyId] != nil {
            for messageData in global.chatData[buddyId]!.messages {
                if !messageData.isMine &&
                    messageData.sentAt > global.chatData[buddyId]!.lastMyReadAt {
                    mustUpdateBadges = true
                }
            }
        }
        
        if mustUpdateBadges {
            global.chatData[buddyId]!.lastMyReadAt = global.getUtcTime()
            global.updateBadges()
            global.firebaseUser!.getIDToken(completion: { (token, error) in
                let postString =
                    "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                    "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                    "buddyId=\(buddyId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
                global.runPhp(script: "readMessages", postString: postString) { json in
                    global.db.collection("accounts")
                        .document(buddyId)
                        .setData(["hasChanged": true], merge: true) { error in }
                }
            })
        }
    }

    func getActionSheet() -> ActionSheet {
        var buttons = [Alert.Button.default(Text("Profile")) {
            mustVisitBuddiesProfile = true
        }]
        
        if !global.blockedBuddyIds.contains(buddyId) {
            buttons += [Alert.Button.destructive(Text("Block")) {
                activeAlert = .block
            }]
        } else {
            buttons += [Alert.Button.default(Text("Unblock")) {
                global.unblock(buddyId: buddyId)
            }]
        }
        
        buttons += [Alert.Button.destructive(Text("Report")) {
            activeSheet = .buddiesProfileReport
        }]

        buttons += [Alert.Button.destructive(Text("Clear Chat History")) {
            activeAlert = .clear
        }]

        return ActionSheet(title: Text("Choose an Option"),
                           buttons: buttons + [Alert.Button.cancel()])
    }
}

struct ChatRoomData: Identifiable, Codable {
    var id = UUID()
    var username: String
    var lastVisitedAt = Date(timeIntervalSince1970: 0)
    var lastMyReadAt = Date(timeIntervalSince1970: 0)
    var lastBuddyReadAt = Date(timeIntervalSince1970: 0)
    var messages: [MessageData]

    init(username: String, messageData: MessageData) {
        self.username = username
        // Make sure ChatRoomData always has at least one message, or it will be nil on didSet.
        self.messages = [messageData]
    }
}
