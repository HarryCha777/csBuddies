//
//  CommentWriteView.swift
//  csBuddies
//
//  Created by Harry Cha on 1/12/21.
//  Copyright © 2021 Harry Cha. All rights reserved.
//

import SwiftUI
import Combine

struct CommentWriteView: View {
    @EnvironmentObject var global: Global
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentation
    
    let byteId: String
    let parentCommentId: String
    @State var comment: String
    @Binding var newCommentId: String
    
    @State private var isPosting = false
    @State private var dailyLimit = 0
    
    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            tooLongComment,
            tooManyCommentsToday,
            prepermission
    }
    
    init(byteId: String,
         parentCommentId: String = "",
         comment: String,
         newCommentId: Binding<String>) {
        self.byteId = byteId
        self.parentCommentId = parentCommentId
        self._comment = State(initialValue: comment)
        self._newCommentId = newCommentId
    }
    
    var body: some View {
        List {
            VStack {
                if parentCommentId == "" {
                    VStack(alignment: .leading) {
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
                        }
                        
                        Text(global.bytes[byteId]!.content)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical)
                } else {
                    VStack(alignment: .leading) {
                        HStack(alignment: .top) {
                            SmallImageView(userId: global.comments[parentCommentId]!.userId, isOnline: global.isOnline(lastVisitedAt: global.comments[parentCommentId]!.lastVisitedAt), size: 35)
                            
                            Spacer()
                                .frame(width: 10)
                            
                            VStack(alignment: .leading) {
                                Text(global.comments[parentCommentId]!.username)
                                    .bold()
                                    .lineLimit(1)
                                Text(global.comments[parentCommentId]!.postedAt.toTimeDifference())
                                    .foregroundColor(.gray)
                                    .font(.footnote)
                            }
                            
                            Spacer()
                        }
                        
                        if global.comments[parentCommentId]!.parentUserId != "00000000-0000-0000-0000-000000000000" {
                            Text("@\(global.comments[parentCommentId]!.parentUsername)")
                                .foregroundColor(.blue)
                        }
                        
                        Text(global.comments[parentCommentId]!.content)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical)
                }
                
                Spacer()
                    .frame(height: 10)
                Divider()
                Spacer()
                    .frame(height: 10)
                
                BetterTextEditor(placeholder: "Type your \(parentCommentId == "" ? "comment" : "reply") here...", text: $comment)
                
                Spacer()
                HStack {
                    Spacer()
                    Text("\(comment.count)/256")
                        .padding()
                        .foregroundColor(comment.count > 256 ? .red : colorScheme == .light ? .black : .white)
                }
            }
            
            if !global.hasAskedNotification {
                Button(action: {
                    activeAlert = .prepermission
                }) {
                    Text("Turn on Notification")
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .disabledOnLoad(isLoading: isPosting)
        .navigationBarTitle(parentCommentId == "" ? "Post a Comment" : "Post a Reply", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                BackButton(title: "Cancel", presentation: presentation)
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    isPosting = true
                    
                    if comment.count > 256 {
                        activeAlert = .tooLongComment
                    } else {
                        addComment()
                    }
                }) {
                    Text("Post")
                }
                .disabled(comment.count == 0 || comment.count > 256 || isPosting)
            }
        }
        .alert(item: $activeAlert) { alert in
            DispatchQueue.main.async {
                isPosting = false
            }
            
            switch alert {
            case .tooLongComment:
                return Alert(title: Text("Too Long Comment"), message: Text("You currently typed \(comment.count) characters. Please type no more than 256 characters."), dismissButton: .default(Text("OK")))
            case .tooManyCommentsToday:
                return Alert(title: Text("Reached Daily Comment Limit"), message: Text("You already posted \(dailyLimit) comments today. Please come back tomorrow."), dismissButton: .default(Text("OK")))
            case .prepermission:
                return Alert(title: Text("Get notified when someone replies to your comments!"),
                             message: Text("Would you like to receive a notification when you get replies?"),
                             primaryButton: .destructive(Text("Not Now")),
                             secondaryButton: .default(Text("Notify Me"), action: {
                                global.askNotification()
                             }))
            }
        }
        .onDisappear {
            // Rapidly updating a global variable is laggy in TabView with lots of content,
            // so use a local variable instead and update the global variable only at the end.
            global.commentDraft = comment
        }
    }
    
    func addComment() {
        global.firebaseUser!.getIDToken(completion: { (token, error) in
            let postString =
                "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "byteId=\(byteId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "parentCommentId=\(parentCommentId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "content=\(comment.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
            global.runHttp(script: "addComment", postString: postString) { json in
                if json["isTooMany"] != nil &&
                    json["isTooMany"] as! Bool {
                    dailyLimit = json["dailyLimit"] as! Int
                    activeAlert = .tooManyCommentsToday
                    return
                }
                
                newCommentId = json["commentId"] as! String
                let commentData = CommentData(
                    commentId: newCommentId,
                    byteId: byteId,
                    userId: global.myId,
                    username: global.username,
                    lastVisitedAt: global.getUtcTime(),
                    parentUserId: parentCommentId == "" ? "00000000-0000-0000-0000-000000000000" : global.comments[parentCommentId]!.userId,
                    parentUsername: parentCommentId == "" ? "" : global.comments[parentCommentId]!.username,
                    content: comment,
                    likes: 0,
                    isLiked: false,
                    postedAt: global.getUtcTime())
                commentData.updateClientData()
                
                comment = ""
                global.commentsMade += 1
                
                presentation.wrappedValue.dismiss()
                global.confirmationText = "Posted"
            }
        })
    }
}

