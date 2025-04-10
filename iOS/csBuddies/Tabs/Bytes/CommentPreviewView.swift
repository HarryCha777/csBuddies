//
//  CommentPreviewView.swift
//  csBuddies
//
//  Created by Harry Cha on 1/11/21.
//  Copyright © 2021 Harry Cha. All rights reserved.
//

import SwiftUI

struct CommentPreviewView: View {
    @EnvironmentObject var global: Global
    
    let commentId: String
    // global.comments[commentId] must be set in advance.
    
    @State private var hasUpdatedClientData = false
    @State private var isUpdatingLike = false
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
        if !global.comments[commentId]!.isDeleted {
            // Note that long press gesture for action sheet inside NavigationLink disables NavigationLink.
            NavigationLinkNoArrow(destination: ByteView(byteId: global.comments[commentId]!.byteId)) {
                VStack(alignment: .leading) {
                    NavigationLinkBorderless(destination: UserView(userId: global.comments[commentId]!.userId)) {
                        HStack(alignment: .top) {
                            SmallImageView(userId: global.comments[commentId]!.userId, isOnline: global.isOnline(lastVisitedAt: global.comments[commentId]!.lastVisitedAt), size: 35)
                            
                            Spacer()
                                .frame(width: 10)
                            
                            VStack(alignment: .leading) {
                                Text(global.comments[commentId]!.username)
                                    .bold()
                                    .lineLimit(1)
                                Text(global.comments[commentId]!.postedAt.toTimeDifference())
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
                    
                    if global.comments[commentId]!.parentUserId != "00000000-0000-0000-0000-000000000000" {
                        NavigationLinkBorderless(destination: UserView(userId: global.comments[commentId]!.parentUserId)) {
                            Text("@\(global.comments[commentId]!.parentUsername)")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    TruncatedText(text: global.comments[commentId]!.content)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    HStack {
                        CommentHeartView(commentId: commentId)
                        Text("\(global.comments[commentId]!.likes)")
                        
                        Spacer()
                        
                        NavigationLinkBorderless(destination: CommentLikesView(commentId: commentId)) {
                            Image(systemName: "person.3.fill")
                                .foregroundColor(.gray)
                            Text("Likes")
                        }
                        
                        Spacer()
                        // Emphasize a button to reply instead of hiding it in an ellipsis menu or tap gestures.
                        // Hide the reply button in preview
                        // because the user must view the full context, including the Byte's comments, before commenting.
                    }
                }
            }
            .padding(.vertical)
            .actionSheet(isPresented: $showActionSheet) {
                getActionSheet()
            }
            .overlay(
                // Place alert here since CommentHeartView's alerts are disabled if alerts are modified to the view wrapping it.
                Spacer()
                    .alert(item: $activeAlert) { alert in
                        switch alert {
                        case .joinToBlock:
                            return Alert(title: Text("Join us to block \(global.comments[commentId]!.username)."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Join"), action: {
                                global.activeRootView = .join
                            }))
                        case .joinToReport:
                            return Alert(title: Text("Join us to report \(global.comments[commentId]!.username)."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Join"), action: {
                                global.activeRootView = .join
                            }))
                        case .block:
                            return Alert(title: Text("Block Buddy"), message: Text("Their profiles, bytes, and comments will be hidden, and you will no longer receive messages or notifications from them. They will never know that you blocked them."), primaryButton: .default(Text("Cancel")), secondaryButton: .destructive(Text("Block"), action: {
                                // Create userPreviewData with only the available information and leave it to be updated later.
                                let userPreviewData = UserPreviewData(
                                    userId: global.comments[commentId]!.userId,
                                    username: global.comments[commentId]!.username,
                                    gender: 3,
                                    birthday: global.getUtcTime(),
                                    country: 0,
                                    intro: "",
                                    lastVisitedAt: Date(timeIntervalSince1970: 0))
                                userPreviewData.updateClientData()
                                global.block(buddyId: global.comments[commentId]!.userId)
                            }))
                        case .delete:
                            return Alert(title: Text("Are you sure?"), message: Text("You cannot undo this action."), primaryButton: .default(Text("Cancel")
                            ), secondaryButton: .destructive(Text("Delete"), action: {
                                global.firebaseUser!.getIDToken(completion: { (token, error) in
                                    let postString =
                                        "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                                        "commentId=\(commentId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
                                    global.runHttp(script: "deleteComment", postString: postString) { json in
                                        global.comments[commentId]!.isDeleted = true
                                        
                                        let hasAlreadyDeleted = json["hasAlreadyDeleted"] as! Bool
                                        if !hasAlreadyDeleted {
                                            global.commentsMade -= 1
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
            UIPasteboard.general.string = global.comments[commentId]!.content
            
            global.confirmationText = "Copied"
        }]
        
        if global.comments[commentId]!.userId != global.myId {
            if !global.blockedBuddyIds.contains(global.comments[commentId]!.userId) {
                buttons += [Alert.Button.destructive(Text("Block")) {
                    if global.myId == "" {
                        activeAlert = .joinToBlock
                    } else {
                        activeAlert = .block
                    }
                }]
            } else {
                buttons += [Alert.Button.default(Text("Unblock")) {
                    global.unblock(buddyId: global.comments[commentId]!.userId)
                }]
            }
        }
        
        if global.comments[commentId]!.userId != global.myId {
            buttons += [Alert.Button.destructive(Text("Report")) {
                if global.myId == "" {
                    activeAlert = .joinToReport
                } else {
                    activeSheet = .buddiesProfileReport
                }
            }]
        }
        
        if global.comments[commentId]!.userId == global.myId {
            buttons += [Alert.Button.destructive(Text("Delete Comment")) {
                activeAlert = .delete
            }]
        }
        
        return ActionSheet(title: Text("Choose an Option"),
                           buttons: buttons + [Alert.Button.cancel()])
    }
}
