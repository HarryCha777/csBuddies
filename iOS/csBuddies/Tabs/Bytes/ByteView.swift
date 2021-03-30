//
//  ByteView.swift
//  csBuddies
//
//  Created by Harry Cha on 1/11/21.
//  Copyright © 2021 Harry Cha. All rights reserved.
//

import SwiftUI

struct ByteView: View {
    @EnvironmentObject var global: Global
    @Environment(\.presentationMode) var presentation
    
    let byteId: String
    // global.bytes[byteId] is not required to be set in advance.
    
    @State private var mustGetByteAndComments = true
    
    @State private var isLoadingByte = false
    @State private var showActionSheet = false
    
    @State private var commentIds = [String]()
    @State private var isLoadingComments = false
    @State private var bottomPostedAt = Date()
    @State private var canLoadMoreComments = true
    
    @State private var newCommentId = ""
    @State private var isCommentDeleted = false
    
    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            joinToLike,
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
            bytesByteWrite
    }
    
    var body: some View {
        ZStack {
            List {
                if isLoadingByte || global.bytes[byteId] == nil {
                    LottieView(name: "load", size: 300, mustLoop: true)
                } else if global.bytes[byteId]!.isDeleted {
                    SimpleView(
                        lottieView: LottieView(name: "noData", size: 300),
                        title: "This byte is deleted.")
                } else {
                    BytePostView(byteId: byteId)
                }
                
                if commentIds.count == 0 && isLoadingComments {
                    Section(header: Text("Comments")) {
                        LottieView(name: "load", size: 300, mustLoop: true)
                    }
                } else if commentIds.count > 0 {
                    Section(header: Text("Comments")) {
                        ForEach(commentIds, id: \.self) { commentId in
                            if !global.blockedBuddyIds.contains(global.comments[commentId]!.userId) {
                                CommentView(commentId: commentId, newCommentId: $newCommentId, isCommentDeleted: $isCommentDeleted)
                            }
                        }
                        // Do not use .id(UUID()) to prevent calling PHP on each tab change.
                        
                        InfiniteScrollView(isLoading: isLoadingComments, isEmpty: commentIds.count == 0, canLoadMore: canLoadMoreComments, loadMore: getByteComments)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            
            if !isLoadingByte && global.bytes[byteId] != nil && !global.bytes[byteId]!.isDeleted {
                FloatingActionButton(systemName: "pencil") {
                    if global.myId == "" {
                        activeAlert = .joinToWrite
                    } else {
                        activeSheet = .bytesByteWrite
                    }
                }
            }
        }
        .navigationBarTitle(global.bytes[byteId] == nil ? "" : global.bytes[byteId]!.username, displayMode: .inline)
        .overlay(
            VStack {
                if newCommentId != "" {
                    Spacer()
                        .onAppear {
                            global.bytes[byteId]!.comments += 1
                            commentIds.insert(newCommentId, at: 0)
                            newCommentId = ""
                        }
                }
                
                if isCommentDeleted {
                    Spacer()
                        .onAppear {
                            global.bytes[byteId]!.comments -= 1
                            isCommentDeleted = false
                        }
                }
            }
        )
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack { // Having at least 2 views inside HStack is necessary to make Image larger.
                    if !isLoadingByte && global.bytes[byteId] != nil && !global.bytes[byteId]!.isDeleted {
                        // Place Spacer inside the if condition or the button below will slide to the left on each refresh.
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
            case .bytesByteWrite:
                NavigationView {
                    CommentWriteView(byteId: byteId, comment: global.commentDraft, newCommentId: $newCommentId)
                        .environmentObject(globalObject)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .joinToLike:
                return Alert(title: Text("Join us to like this byte."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Join"), action: {
                    global.activeRootView = .join
                }))
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
                        gender: 3,
                        birthday: global.getUtcTime(),
                        country: 0,
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
                            "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                            "byteId=\(byteId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
                        global.runHttp(script: "deleteByte", postString: postString) { json in
                            global.bytes[byteId]!.isDeleted = true
                            
                            let hasAlreadyDeleted = json["hasAlreadyDeleted"] as! Bool
                            if !hasAlreadyDeleted {
                                global.bytesMade -= 1
                            }
                            
                            presentation.wrappedValue.dismiss()
                            global.confirmationText = "Deleted"
                        }
                    })
                }))
            case .joinToWrite:
                return Alert(title: Text("Join us to write a comment."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Join"), action: {
                    global.activeRootView = .join
                }))
            }
        }
        .refresh(isRefreshing: $mustGetByteAndComments, isRefreshingBool: mustGetByteAndComments) {
            bottomPostedAt = Date(timeIntervalSince1970: 0)
            commentIds.removeAll()
            getByte()
            getByteComments()
        }
    }
    
    func getByte() {
        if isLoadingByte {
            return
        }
        isLoadingByte = true
        
        global.getTokenIfSignedIn { token in
            let postString =
                "token=\(token.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "byteId=\(byteId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
            global.runHttp(script: "getByte", postString: postString) { json in
                if json["isDeleted"] != nil &&
                    json["isDeleted"] as! Bool {
                    var byteData = ByteData(byteId: byteId, userId: "", username: "", lastVisitedAt: global.getUtcTime(), content: "", likes: 0, comments: 0, isLiked: false, postedAt: global.getUtcTime())
                    byteData.isDeleted = true
                    byteData.updateClientData()
                    
                    mustGetByteAndComments = false
                    isLoadingByte = false
                    return
                }
                
                let byteData = ByteData(
                    byteId: byteId,
                    userId: json["userId"] as! String,
                    username: json["username"] as! String,
                    lastVisitedAt: (json["lastVisitedAt"] as! String).toDate(),
                    content: json["content"] as! String,
                    likes: json["likes"] as! Int,
                    comments: json["comments"] as! Int,
                    isLiked: json["isLiked"] as! Bool,
                    postedAt: (json["postedAt"] as! String).toDate())
                byteData.updateClientData()
                
                mustGetByteAndComments = false
                isLoadingByte = false
            }
        }
    }
    
    func getByteComments() {
        isLoadingComments = true
        canLoadMoreComments = true
        
        global.getTokenIfSignedIn { token in
            let postString =
                "token=\(token.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "byteId=\(byteId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "bottomPostedAt=\(bottomPostedAt.toString())"
            global.runHttp(script: "getByteComments", postString: postString) { json in
                if json.count <= 1 {
                    mustGetByteAndComments = false
                    isLoadingComments = false
                    canLoadMoreComments = false
                    return
                }
                
                for i in 0...json.count - 2 {
                    let row = json[String(i)] as! NSDictionary
                    let commentData = CommentData(
                        commentId: row["commentId"] as! String,
                        byteId: byteId,
                        userId: row["userId"] as! String,
                        username: row["username"] as! String,
                        lastVisitedAt: (row["lastVisitedAt"] as! String).toDate(),
                        parentUserId: row["parentUserId"] as! String,
                        parentUsername: row["parentUsername"] as! String,
                        content: row["content"] as! String,
                        likes: row["likes"] as! Int,
                        isLiked: row["isLiked"] as! Bool,
                        postedAt: (row["postedAt"] as! String).toDate())
                    commentData.updateClientData()
                    commentIds.append(commentData.commentId)
                }
                
                let lastRow = json[String(json.count - 1)] as! NSDictionary
                bottomPostedAt = (lastRow["bottomPostedAt"] as! String).toDate()
                
                mustGetByteAndComments = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Prevent calling PHP twice on each load.
                    isLoadingComments = false
                }
            }
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

struct ByteData: Identifiable, Codable {
    var id = UUID()
    var byteId: String
    var userId: String
    var username: String
    var lastVisitedAt: Date
    var content: String
    var likes: Int
    var comments: Int
    var isLiked: Bool
    var postedAt: Date
    var isDeleted = false
    
    init(byteId: String,
         userId: String,
         username: String,
         lastVisitedAt: Date,
         content: String,
         likes: Int,
         comments: Int,
         isLiked: Bool,
         postedAt: Date) {
        self.byteId = byteId
        self.userId = userId
        self.username = username
        self.lastVisitedAt = lastVisitedAt
        self.content = content
        self.likes = likes
        self.comments = comments
        self.isLiked = isLiked
        self.postedAt = postedAt
    }
    
    func updateClientData() {
        globalObject.bytes[byteId] = self
        
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
