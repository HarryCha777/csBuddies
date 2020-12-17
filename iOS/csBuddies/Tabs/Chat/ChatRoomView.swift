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
                ChatRoomListView(buddyId: buddyId)
                Spacer()
                ChatRoomInputView(buddyId: buddyId, buddyUsername: buddyUsername, message: global.messageDrafts[buddyId] ?? "")
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
                            Image(systemName: "ellipsis.circle")
                                .font(.largeTitle)
                        }
                    }
                }
            }
            
            NavigationLinkEmpty(destination: BuddiesProfileView(buddyId: buddyId), isActive: $mustVisitBuddiesProfile)
            
            // Place alert here since ChatRoomInputView's alerts are disabled if alerts are modified to the view wrapping it.
            Spacer()
                .alert(item: $activeAlert) { alert in
                    switch alert {
                    case .block:
                        return Alert(title: Text("Block Buddy"), message: Text("You will no longer receive messages or notifications from them. Their activity will also be hidden from your Buddies and Bytes tabs. They will never know that you blocked them."), primaryButton: .default(Text("Cancel")), secondaryButton: .destructive(Text("Block"), action: {
                            global.block(buddyId: buddyId, buddyUsername: global.chatBuddyUsername)
                        }))
                    case .clear:
                        return Alert(title: Text("Are you sure?"), message: Text("You cannot undo this action."), primaryButton: .default(Text("Cancel")
                        ), secondaryButton: .destructive(Text("Clear"), action: {
                            global.chatData[buddyId] = nil
                            
                            presentation.wrappedValue.dismiss()
                            global.confirmationText = "Cleared"
                        }))
                    }
                }
        }
        .actionSheet(isPresented: $showActionSheet) {
            getActionSheet()
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .buddiesProfileReport:
                NavigationView {
                    BuddiesProfileReportView(buddyId: buddyId)
                        .environmentObject(globalObject)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
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
        }
    }
    
    func markAllRead() {
        var mustUpdateBadges = false
        if global.chatData[buddyId] != nil {
            for index in global.chatData[buddyId]!.messages.indices {
                if !global.chatData[buddyId]!.messages[index].isMine &&
                    global.chatData[buddyId]!.messages[index].sendTime > global.chatData[buddyId]!.lastBuddyReadTime {
                    mustUpdateBadges = true
                }
            }
        }
        
        if mustUpdateBadges {
            let now = global.getUtcTime()
            global.chatData[buddyId]!.lastMyReadTime = now
            global.updateBadges()
            global.db.collection("messageUpdates")
                .whereField("myId", isEqualTo: global.myId)
                .whereField("buddyId", isEqualTo: buddyId)
                .getDocuments { (snapshot, error) in
                    if snapshot!.documents.count == 0 {
                        global.db.collection("messageUpdates")
                            .addDocument(data: [
                                            "myId": global.myId,
                                            "myUsername": global.username,
                                            "buddyId": buddyId,
                                            "lastReadTime": now,
                                            "lastSendTime": Date(timeIntervalSince1970: 0)])
                    } else {
                        snapshot!.documents[0].reference
                            .setData(["myUsername": global.username, "lastReadTime": now], merge: true)
                    }
            }
        }
    }

    func getActionSheet() -> ActionSheet {
        var buttons = [Alert.Button.default(Text("Profile")) {
            mustVisitBuddiesProfile = true
        }]
        
        if !global.blocks.contains(where: { $0.userId == buddyId }) {
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
    var isOnline = false
    var lastMyReadTime = Date(timeIntervalSince1970: 0)
    var lastBuddyReadTime = Date(timeIntervalSince1970: 0)
    var lastBuddySendTime = Date(timeIntervalSince1970: 0)
    var messages = [ChatRoomMessageData]()

    init(username: String) {
        self.username = username
    }
}
