//
//  UserProfileView.swift
//  csBuddies
//
//  Created by Harry Cha on 11/1/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var global: Global
    @Environment(\.colorScheme) var colorScheme
    
    let userId: String
    // global.users[userId] must be set in advance.
    @Binding var mustGetBytesAndComments: Bool
    
    @State private var mustVisitBigImage = false
    @State private var bytesAndCommentsTabIndex = 0
    
    @State private var byteIds = [String]()
    @State private var isLoadingBytes = false
    @State private var canLoadMoreBytes = true
    @State private var bottomBytePostedAt = Date()
    
    @State private var commentIds = [String]()
    @State private var isLoadingComments = false
    @State private var canLoadMoreComments = true
    @State private var bottomCommentPostedAt = Date()
    
    @State private var likedByteIds = [String]()
    @State private var isLoadingLikedBytes = false
    @State private var canLoadMoreLikedBytes = true
    @State private var bottomLikedByteLastUpdatedAt = Date()
    
    @State private var likedCommentIds = [String]()
    @State private var isLoadingLikedComments = false
    @State private var canLoadMoreLikedComments = true
    @State private var bottomLikedCommentLastUpdatedAt = Date()
    
    var body: some View {
        Group {
            HStack {
                VStack {
                    Spacer()
                    Button(action: {
                        mustVisitBigImage = true
                    }) {
                        SmallImageView(userId: userId, isOnline: global.isOnline(lastVisitedAt: global.users[userId]!.lastVisitedAt), size: 75)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .fullScreenCover(isPresented: $mustVisitBigImage) {
                        BigImageView(userId: userId)
                    }
                    Spacer()
                }
                
                Spacer()
                    .frame(width: 10)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(global.users[userId]!.username)
                            .bold()
                        Spacer()
                        if global.users[userId]!.isAdmin {
                            Text("Admin")
                                .bold()
                                .foregroundColor(Color.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.green)
                                .cornerRadius(5)
                                .multilineTextAlignment(.center)
                        }
                    }
                    HStack {
                        if global.users[userId]!.genderIndex == 0 {
                            Text(global.genderOptions[global.users[userId]!.genderIndex])
                                .font(.footnote)
                                .foregroundColor(.blue) +
                                Text(",")
                                .font(.footnote)
                        } else if global.users[userId]!.genderIndex == 1 {
                            Text(global.genderOptions[global.users[userId]!.genderIndex])
                                .font(.footnote)
                                .foregroundColor(Color(red: 255 / 255, green: 20 / 255, blue: 147 / 255)) + // This is pink
                                Text(",")
                                .font(.footnote)
                        } else if global.users[userId]!.genderIndex == 2 ||
                                    global.users[userId]!.genderIndex == 3 {
                            Text(global.genderOptions[global.users[userId]!.genderIndex])
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
                        Text(global.users[userId]!.birthday.toString()[0] != "0" ? "\(global.users[userId]!.birthday.toAge())" : "N/A")
                            .font(.footnote)
                    }
                    Text(global.countryOptions[safe: global.users[userId]!.countryIndex] ?? "Unknown")
                        .font(.footnote)
                    if global.isOnline(lastVisitedAt: global.users[userId]!.lastVisitedAt) {
                        Text("Online now")
                            .foregroundColor(.green)
                            .font(.footnote)
                    } else {
                        Text("Online \(Calendar.current.date(byAdding: .second, value: global.onlineTimeout, to: global.users[userId]!.lastVisitedAt)!.toTimeDifference(hasExtension: true))")
                            .foregroundColor(.gray)
                            .font(.footnote)
                    }
                }
            }
            
            Section(header: Text("Self-Introduction")) {
                Text(global.users[userId]!.intro)
                if global.users[userId]!.github.count != 0 {
                    NavigationLink(destination:
                                    WebView(request: URLRequest(url: (URL(string: "https://www.github.com/\(global.users[userId]!.github)") ?? URL(string: "https://www.github.com"))!))
                                    .navigationBarTitle("GitHub", displayMode: .inline)
                    ) {
                        Image("githubLogo")
                            .resizable()
                            .frame(width: 22, height: 22)
                            .if(colorScheme == .dark) { content in
                                content.colorInvert() // Invert color on dark mode.
                            }
                        Text("github.com/\(global.users[userId]!.github)")
                            .foregroundColor(.blue)
                    }
                }
                if global.users[userId]!.linkedin.count != 0 {
                    NavigationLink(destination:
                                    WebView(request: URLRequest(url: (URL(string: "https://linkedin.com/in/\(global.users[userId]!.linkedin)") ?? URL(string: "https://linkedin.com"))!))
                                    .navigationBarTitle("LinkedIn", displayMode: .inline)
                    ) {
                        Image("linkedinLogo")
                            .resizable()
                            .frame(width: 22, height: 22)
                        Text("linkedin.com/in/\(global.users[userId]!.linkedin)")
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Section(header: Text("Interests")) {
                if global.users[userId]!.interests.count == 0 {
                    Text("No interests selected.")
                } else {
                    TagsView(data: global.users[userId]!.interests) { interest in
                        InterestsButtonDisabledView(interest: interest, interests: global.users[userId]!.interests)
                    }
                }
            }
            
            Section(header: EmptyView()) {
                VStack {
                    SlidingTabView(selection: $bytesAndCommentsTabIndex, tabs: ["Bytes", "Comments", "Liked\nBytes", "Liked\nComments"])
                    
                    switch bytesAndCommentsTabIndex {
                    case 0:
                        HStack(spacing: 0) {
                            if global.users[userId]!.bytesMade == 0 {
                                Text("Has no bytes & ")
                                    .font(.footnote)
                            } else if global.users[userId]!.bytesMade == 1 {
                                Text("Has 1 byte & ")
                                    .font(.footnote)
                            } else {
                                Text("Has \(global.users[userId]!.bytesMade) bytes & ")
                                    .font(.footnote)
                            }
                            
                            if global.users[userId]!.byteLikesReceived == 0 {
                                Text("no likes")
                                    .font(.footnote)
                            } else if global.users[userId]!.byteLikesReceived == 1 {
                                Text("1 like")
                                    .font(.footnote)
                            } else {
                                Text("\(global.users[userId]!.byteLikesReceived) likes")
                                    .font(.footnote)
                            }
                        }
                    case 1:
                        HStack(spacing: 0) {
                            if global.users[userId]!.commentsMade == 0 {
                                Text("Has no comments & ")
                                    .font(.footnote)
                            } else if global.users[userId]!.commentsMade == 1 {
                                Text("Has 1 comment & ")
                                    .font(.footnote)
                            } else {
                                Text("Has \(global.users[userId]!.commentsMade) comments & ")
                                    .font(.footnote)
                            }
                            
                            if global.users[userId]!.commentLikesReceived == 0 {
                                Text("no likes")
                                    .font(.footnote)
                            } else if global.users[userId]!.commentLikesReceived == 1 {
                                Text("1 like")
                                    .font(.footnote)
                            } else {
                                Text("\(global.users[userId]!.commentLikesReceived) likes")
                                    .font(.footnote)
                            }
                        }
                    case 2:
                        if global.users[userId]!.byteLikesGiven == 0 {
                            Text("Likes no bytes")
                                .font(.footnote)
                        } else if global.users[userId]!.byteLikesGiven == 1 {
                            Text("Likes 1 byte")
                                .font(.footnote)
                        } else {
                            Text("Likes \(global.users[userId]!.byteLikesGiven) bytes")
                                .font(.footnote)
                        }
                    case 3:
                        if global.users[userId]!.commentLikesGiven == 0 {
                            Text("Likes no comments")
                                .font(.footnote)
                        } else if global.users[userId]!.commentLikesGiven == 1 {
                            Text("Likes 1 comment")
                                .font(.footnote)
                        } else {
                            Text("Likes \(global.users[userId]!.commentLikesGiven) comments")
                                .font(.footnote)
                        }
                    default:
                        EmptyView()
                    }
                }
                
                switch bytesAndCommentsTabIndex {
                case 0:
                    if global.users[userId]!.bytesMade > 0 {
                        ForEach(byteIds, id: \.self) { byteId in
                            BytePreviewView(byteId: byteId)
                        }
                        // Do not use .id(UUID()) or bytes do not change when they are liked.
                        
                        InfiniteScrollView(isLoading: isLoadingBytes, isEmpty: byteIds.count == 0, canLoadMore: canLoadMoreBytes, loadMore: getBytes)
                    }
                case 1:
                    if global.users[userId]!.commentsMade > 0 {
                        ForEach(commentIds, id: \.self) { commentId in
                            CommentPreviewView(commentId: commentId)
                        }
                        // Do not use .id(UUID()) or comments do not change when they are liked.
                        
                        InfiniteScrollView(isLoading: isLoadingComments, isEmpty: commentIds.count == 0, canLoadMore: canLoadMoreComments, loadMore: getComments)
                    }
                case 2:
                    if global.users[userId]!.byteLikesGiven > 0 {
                        ForEach(likedByteIds, id: \.self) { byteId in
                            BytePreviewView(byteId: byteId)
                        }
                        // Do not use .id(UUID()) or bytes do not change when they are liked.
                        
                        InfiniteScrollView(isLoading: isLoadingLikedBytes, isEmpty: likedByteIds.count == 0, canLoadMore: canLoadMoreLikedBytes, loadMore: getLikedBytes)
                    }
                case 3:
                    if global.users[userId]!.commentLikesGiven > 0 {
                        ForEach(likedCommentIds, id: \.self) { commentId in
                            CommentPreviewView(commentId: commentId)
                        }
                        // Do not use .id(UUID()) or comments do not change when they are liked.
                        
                        InfiniteScrollView(isLoading: isLoadingLikedComments, isEmpty: likedCommentIds.count == 0, canLoadMore: canLoadMoreLikedComments, loadMore: getLikedComments)
                    }
                default:
                    EmptyView()
                }
            }
        }
        .overlay(
            VStack {
                if mustGetBytesAndComments {
                    Spacer()
                        .onAppear {
                            mustGetBytesAndComments = false
                            bytesAndCommentsTabIndex = 0
                            bottomBytePostedAt = global.getUtcTime()
                            bottomCommentPostedAt = global.getUtcTime()
                            bottomLikedByteLastUpdatedAt = global.getUtcTime()
                            bottomLikedCommentLastUpdatedAt = global.getUtcTime()
                            byteIds.removeAll()
                            commentIds.removeAll()
                            likedByteIds.removeAll()
                            likedCommentIds.removeAll()
                            getBytes()
                            getComments()
                            getLikedBytes()
                            getLikedComments()
                        }
                }
            }
        )
    }
    
    func getBytes() {
        if isLoadingBytes {
            return
        }
        isLoadingBytes = true
        canLoadMoreBytes = true
        
        global.getTokenIfSignedIn { token in
            let postString =
                "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "token=\(token.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "userId=\(userId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "bottomPostedAt=\(bottomBytePostedAt.toString())"
            global.runPhp(script: "getBytes", postString: postString) { json in
                if json.count <= 1 {
                    isLoadingBytes = false
                    canLoadMoreBytes = false
                    return
                }
                
                for i in 1...json.count - 1 {
                    let row = json[String(i)] as! NSDictionary
                    let byteData = ByteData(
                        byteId: row["byteId"] as! String,
                        userId: userId,
                        username: global.users[userId]!.username,
                        lastVisitedAt: global.users[userId]!.lastVisitedAt,
                        content: row["content"] as! String,
                        likes: row["likes"] as! Int,
                        comments: row["comments"] as! Int,
                        isLiked: row["isLiked"] as! Bool,
                        postedAt: (row["postedAt"] as! String).toDate())
                    byteData.updateClientData()
                    byteIds.append(byteData.byteId)
                }
                
                let lastRow = json[String(json.count)] as! NSDictionary
                bottomBytePostedAt = (lastRow["bottomPostedAt"] as! String).toDate()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Prevent calling PHP twice on each load.
                    isLoadingBytes = false
                }
            }
        }
    }
    
    func getComments() {
        if isLoadingComments {
            return
        }
        isLoadingComments = true
        canLoadMoreComments = true
        
        global.getTokenIfSignedIn { token in
            let postString =
                "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "token=\(token.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "userId=\(userId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "bottomPostedAt=\(bottomCommentPostedAt.toString())"
            global.runPhp(script: "getComments", postString: postString) { json in
                if json.count <= 1 {
                    isLoadingComments = false
                    canLoadMoreComments = false
                    return
                }
                
                for i in 1...json.count - 1 {
                    let row = json[String(i)] as! NSDictionary
                    let commentData = CommentData(
                        commentId: row["commentId"] as! String,
                        byteId: row["byteId"] as! String,
                        userId: userId,
                        username: global.users[userId]!.username,
                        lastVisitedAt: global.users[userId]!.lastVisitedAt,
                        parentUserId: row["parentUserId"] as! String,
                        parentUsername: row["parentUsername"] as! String,
                        content: row["content"] as! String,
                        likes: row["likes"] as! Int,
                        isLiked: row["isLiked"] as! Bool,
                        postedAt: (row["postedAt"] as! String).toDate())
                    commentData.updateClientData()
                    commentIds.append(commentData.commentId)
                }
                
                let lastRow = json[String(json.count)] as! NSDictionary
                bottomCommentPostedAt = (lastRow["bottomPostedAt"] as! String).toDate()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Prevent calling PHP twice on each load.
                    isLoadingComments = false
                }
            }
        }
    }
    
    func getLikedBytes() {
        if isLoadingLikedBytes {
            return
        }
        isLoadingLikedBytes = true
        canLoadMoreLikedBytes = true
        
        global.getTokenIfSignedIn { token in
            let postString =
                "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "token=\(token.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "userId=\(userId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "bottomLastUpdatedAt=\(bottomLikedByteLastUpdatedAt.toString())"
            global.runPhp(script: "getLikedBytes", postString: postString) { json in
                if json.count <= 1 {
                    isLoadingLikedBytes = false
                    canLoadMoreLikedBytes = false
                    return
                }
                
                for i in 1...json.count - 1 {
                    let row = json[String(i)] as! NSDictionary
                    let byteData = ByteData(
                        byteId: row["byteId"] as! String,
                        userId: row["userId"] as! String,
                        username: row["username"] as! String,
                        lastVisitedAt: (row["lastVisitedAt"] as! String).toDate(),
                        content: row["content"] as! String,
                        likes: row["likes"] as! Int,
                        comments: row["comments"] as! Int,
                        isLiked: row["isLiked"] as! Bool,
                        postedAt: (row["postedAt"] as! String).toDate())
                    byteData.updateClientData()
                    likedByteIds.append(byteData.byteId)
                }
                
                let lastRow = json[String(json.count)] as! NSDictionary
                bottomLikedByteLastUpdatedAt = (lastRow["bottomLastUpdatedAt"] as! String).toDate()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Prevent calling PHP twice on each load.
                    isLoadingLikedBytes = false
                }
            }
        }
    }
    
    func getLikedComments() {
        if isLoadingLikedComments {
            return
        }
        isLoadingLikedComments = true
        canLoadMoreLikedComments = true
        
        global.getTokenIfSignedIn { token in
            let postString =
                "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "token=\(token.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "userId=\(userId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "bottomLastUpdatedAt=\(bottomLikedCommentLastUpdatedAt.toString())"
            global.runPhp(script: "getLikedComments", postString: postString) { json in
                if json.count <= 1 {
                    isLoadingLikedComments = false
                    canLoadMoreLikedComments = false
                    return
                }
                
                for i in 1...json.count - 1 {
                    let row = json[String(i)] as! NSDictionary
                    let commentData = CommentData(
                        commentId: row["commentId"] as! String,
                        byteId: row["byteId"] as! String,
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
                    likedCommentIds.append(commentData.commentId)
                }
                
                let lastRow = json[String(json.count)] as! NSDictionary
                bottomLikedCommentLastUpdatedAt = (lastRow["bottomLastUpdatedAt"] as! String).toDate()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Prevent calling PHP twice on each load.
                    isLoadingLikedComments = false
                }
            }
        }
    }
}
