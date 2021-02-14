//
//  BytePreviewView.swift
//  csBuddies
//
//  Created by Harry Cha on 1/11/21.
//  Copyright © 2021 Harry Cha. All rights reserved.
//

import SwiftUI

struct BytePreviewView: View {
    @EnvironmentObject var global: Global
    
    let byteId: String
    // global.bytes[byteId] must be set in advance.
    
    @State private var showActionSheet = false
    
    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            joinToBlock,
            joinToReport,
            block,
            delete
    }
    
    @State var activeSheet: Sheets?
    enum Sheets: Identifiable {
        var id: Int { self.hashValue }
        case
            buddiesProfileReport
    }
    
    var body: some View {
        if !global.bytes[byteId]!.isDeleted {
            // Note that long press gesture for action sheet inside NavigationLink disables NavigationLink.
            NavigationLinkNoArrow(destination: ByteView(byteId: byteId)) {
                VStack(alignment: .leading) {
                    NavigationLinkBorderless(destination: UserView(userId: global.bytes[byteId]!.userId)) {
                        HStack(alignment: .top) {
                            SmallImageView(userId: global.bytes[byteId]!.userId, isOnline: global.isOnline(lastVisitedAt: global.bytes[byteId]!.lastVisitedAt), size: 35)
                            
                            Spacer()
                                .frame(width: 10)
                            
                            VStack(alignment: .leading) {
                                Text(global.bytes[byteId]!.username)
                                    .bold()
                                    .lineLimit(1)
                                Text(global.bytes[byteId]!.postedAt.toTimeDifference())
                                    .foregroundColor(.gray)
                                    .font(.footnote)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                showActionSheet = true
                            }) {
                                Image(systemName: "ellipsis")
                            }
                            .buttonStyle(PlainButtonStyle())
                            .buttonStyle(BorderlessButtonStyle()) // Prevent button from being triggered when anywhere on view is clicked.
                        }
                    }
                    
                    TruncatedText(text: global.bytes[byteId]!.content)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    HStack {
                        ByteHeartView(byteId: byteId)
                        Text("\(global.bytes[byteId]!.likes)")
                        
                        Spacer()
                        
                        NavigationLinkBorderless(destination: ByteLikesView(byteId: byteId)) {
                            Image(systemName: "person.3.fill")
                                .foregroundColor(.gray)
                            Text("Likes")
                        }
                        
                        Spacer()
                        
                        Image(systemName: "bubble.left.fill")
                            .foregroundColor(.gray)
                        Text("\(global.bytes[byteId]!.comments)")
                        
                        // Unlike comment reply buttons, do not have a button to directly comment on the Byte except in ByteView
                        // because the user must view the full context, including the Byte's comments, before commenting.
                    }
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
                        ReportView(buddyId: global.bytes[byteId]!.userId)
                            .environmentObject(globalObject)
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                }
            }
            .overlay(
                // Place alerts here because ByteHeartView's alerts are disabled if alerts are modified to the view wrapping it.
                Spacer()
                    .alert(item: $activeAlert) { alert in
                        switch alert {
                        case .joinToBlock:
                            return Alert(title: Text("Join us to block \(global.bytes[byteId]!.username)."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Join"), action: {
                                global.activeRootView = .join
                            }))
                        case .joinToReport:
                            return Alert(title: Text("Join us to report \(global.bytes[byteId]!.username)."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Join"), action: {
                                global.activeRootView = .join
                            }))
                        case .block:
                            return Alert(title: Text("Block Buddy"), message: Text("Their profiles, bytes, and comments will be hidden, and you will no longer receive messages or notifications from them. They will never know that you blocked them."), primaryButton: .default(Text("Cancel")), secondaryButton: .destructive(Text("Block"), action: {
                                // Create userPreviewData with only the available information and leave it to be updated later.
                                let userPreviewData = UserPreviewData(
                                    userId: global.bytes[byteId]!.userId,
                                    username: global.bytes[byteId]!.username,
                                    birthday: global.getUtcTime(),
                                    genderIndex: 3,
                                    countryIndex: 0,
                                    intro: "",
                                    lastVisitedAt: Date(timeIntervalSince1970: 0))
                                userPreviewData.updateClientData()
                                global.block(buddyId: global.bytes[byteId]!.userId)
                            }))
                        case .delete:
                            return Alert(title: Text("Are you sure?"), message: Text("You cannot undo this action."), primaryButton: .default(Text("Cancel")
                            ), secondaryButton: .destructive(Text("Delete"), action: {
                                global.firebaseUser!.getIDToken(completion: { (token, error) in
                                    let postString =
                                        "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                                        "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                                        "byteId=\(byteId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
                                    global.runPhp(script: "deleteByte", postString: postString) { json in
                                        global.bytes[byteId]!.isDeleted = true
                                        
                                        let hasAlreadyDeleted = json["hasAlreadyDeleted"] as! Bool
                                        if !hasAlreadyDeleted {
                                            global.bytesMade -= 1
                                        }
                                        
                                        global.confirmationText = "Deleted"
                                    }
                                })
                            }))
                        }
                    }
            )
        }
    }
    
    func getActionSheet() -> ActionSheet {
        var buttons = [Alert.Button.default(Text("Copy")) {
            UIPasteboard.general.string = global.bytes[byteId]!.content
            
            global.confirmationText = "Copied"
        }]
        
        if global.bytes[byteId]!.userId != global.myId {
            if !global.blockedBuddyIds.contains(global.bytes[byteId]!.userId) {
                buttons += [Alert.Button.destructive(Text("Block")) {
                    if global.myId == "" {
                        activeAlert = .joinToBlock
                    } else {
                        activeAlert = .block
                    }
                }]
            } else {
                buttons += [Alert.Button.default(Text("Unblock")) {
                    global.unblock(buddyId: global.bytes[byteId]!.userId)
                }]
            }
        }
        
        if global.bytes[byteId]!.userId != global.myId {
            buttons += [Alert.Button.destructive(Text("Report")) {
                if global.myId == "" {
                    activeAlert = .joinToReport
                } else {
                    activeSheet = .buddiesProfileReport
                }
            }]
        }
        
        if global.bytes[byteId]!.userId == global.myId {
            buttons += [Alert.Button.destructive(Text("Delete Byte")) {
                activeAlert = .delete
            }]
        }
        
        return ActionSheet(title: Text("Choose an Option"),
                           buttons: buttons + [Alert.Button.cancel()])
    }
}
