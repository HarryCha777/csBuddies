//
//  CommentView.swift
//  csBuddies
//
//  Created by Harry Cha on 1/11/21.
//  Copyright © 2021 Harry Cha. All rights reserved.
//

import SwiftUI

struct CommentView: View {
    @EnvironmentObject var global: Global
    
    let commentId: String
    // global.comments[commentId] must be set in advance.
    
    @State private var hasUpdatedClientData = false
    @State private var isUpdatingLike = false
    @State private var showActionSheet = false
    
    @Binding var newCommentId: String
    @Binding var isCommentDeleted: Bool
    
    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            joinToBlock,
            joinToReport,
            block,
            delete,
            joinToWrite
    }
    
    @State var activeSheet: Sheets?
    enum Sheets: Identifiable {
        var id: Int { self.hashValue }
        case
            buddiesProfileReport,
            bytesByteCommentWrite
    }
    
    var body: some View {
        if !global.comments[commentId]!.isDeleted {
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
                    Button(action: {
                        if global.myId == "" {
                            activeAlert = .joinToWrite
                        } else {
                            activeSheet = .bytesByteCommentWrite
                        }
                    }) {
                        Image(systemName: "arrowshape.turn.up.left.fill")
                            .foregroundColor(.gray)
                        Text("Reply")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .buttonStyle(BorderlessButtonStyle()) // Prevent button from being triggered when anywhere on view is clicked.
                }
            }
            .padding(.vertical)
            .actionSheet(isPresented: $showActionSheet) {
                getActionSheet()
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .buddiesProfileReport:
                    NavigationView {
                        ReportView(buddyId: global.comments[commentId]!.userId)
                            .environmentObject(globalObject)
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                case .bytesByteCommentWrite:
                    NavigationView {
                        CommentWriteView(byteId: global.comments[commentId]!.byteId, parentCommentId: commentId, newCommentId: $newCommentId)
                            .environmentObject(globalObject)
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                }
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
                                    birthday: global.getUtcTime(),
                                    genderIndex: 3,
                                    countryIndex: 0,
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
                                        "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                                        "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                                        "commentId=\(commentId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
                                    global.runPhp(script: "deleteComment", postString: postString) { json in
                                        global.comments[commentId]!.isDeleted = true
                                        
                                        let hasAlreadyDeleted = json["hasAlreadyDeleted"] as! Bool
                                        if !hasAlreadyDeleted {
                                            global.commentsMade -= 1
                                        }
                                        
                                        global.confirmationText = "Deleted"
                                        
                                        isCommentDeleted = true
                                    }
                                })
                            }))
                        case .joinToWrite:
                            return Alert(title: Text("Join us to reply to a comment."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Join"), action: {
                                global.activeRootView = .join
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

struct CommentData: Identifiable, Codable {
    var id = UUID()
    var commentId: String
    var byteId: String
    var userId: String
    var username: String
    var lastVisitedAt: Date
    var parentUserId: String
    var parentUsername: String
    var content: String
    var likes: Int
    var isLiked: Bool
    var postedAt: Date
    var isDeleted = false
    
    init(commentId: String,
         byteId: String,
         userId: String,
         username: String,
         lastVisitedAt: Date,
         parentUserId: String,
         parentUsername: String,
         content: String,
         likes: Int,
         isLiked: Bool,
         postedAt: Date) {
        self.commentId = commentId
        self.byteId = byteId
        self.userId = userId
        self.username = username
        self.lastVisitedAt = lastVisitedAt
        self.parentUserId = parentUserId
        self.parentUsername = parentUsername
        self.content = content
        self.likes = likes
        self.isLiked = isLiked
        self.postedAt = postedAt
    }
    
    func updateClientData() {
        globalObject.comments[commentId] = self
        
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
