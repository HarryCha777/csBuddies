//
//  BytesPostView.swift
//  csBuddies
//
//  Created by Harry Cha on 10/15/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct BytesPostView: View {
    @EnvironmentObject var global: Global
    
    @State var bytesPostData: BytesPostData // Use "@State var" instead of "let" to update the view when byte is liked.
    @State private var hasExpanded = false
    @State private var hasTruncated = false
    @State private var isUpdatingLike = false
    @State private var showActionSheet = false
    @State private var mustVisitBytesPostLikers = false
    
    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            joinToSave,
            joinToLike,
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
        VStack {
            if bytesPostData.isDeleted {
                HStack {
                    Text("Your byte is deleted.")
                        .font(.footnote)
                    Spacer()
                }
            } else {
                ZStack {
                    VStack(alignment: .leading) {
                        HStack {
                            NavigationLinkBorderless(destination:
                                                        VStack {
                                                            if global.myId == bytesPostData.userId {
                                                                ProfileView()
                                                            } else {
                                                                BuddiesProfileView(buddyId: bytesPostData.userId)
                                                            }
                                                        }) {
                                HStack {
                                    SmallImageView(userId: bytesPostData.userId, isOnline: bytesPostData.isOnline, size: 35, myImage: global.smallImage)
                                    Text(bytesPostData.username)
                                        .bold()
                                        .lineLimit(1)
                                }
                            }
                            Spacer()
                            Text(bytesPostData.postTime.toTimeDifference())
                        }
                        
                        TruncatedText(text: bytesPostData.content, hasExpanded: $hasExpanded, hasTruncated: $hasTruncated)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.black.opacity(0.001)) // Expand button's tappable area to empty spaces.
                            .onTapGesture { } // Prevent scrolling from being disabled due to onLongPressGesture.
                            // onTapGesture(count: x) is disabled due to UITapGestureRecognizer in csBuddiesApp.
                            .onLongPressGesture {
                                showActionSheet = true
                            }
                        
                        Spacer()
                            .frame(width: 5)
                        
                        HStack {
                            if bytesPostData.userId == global.myId {
                                Image(systemName: "heart.fill")
                                    .imageScale(.large)
                                    .foregroundColor(Color.gray)
                            } else {
                                /*if isUpdatingLike {
                                 LottieView(name: "like", size: 75)
                                 }*/
                                if !bytesPostData.isLiked {
                                    Button(action: {
                                        if global.myId == "" {
                                            activeAlert = .joinToLike
                                        } else {
                                            isUpdatingLike = true
                                            bytesPostData.isLiked = true
                                            bytesPostData.likes += 1
                                            
                                            let postString =
                                                "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                                                "password=\(global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                                                "byteId=\(bytesPostData.byteId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                                                "buddyId=\(bytesPostData.userId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
                                            global.runPhp(script: "likeByte", postString: postString) { json in
                                                isUpdatingLike = false
                                                
                                                // User may have already liked the byte on another screen.
                                                let hasAlreadyLiked = json["hasAlreadyLiked"] as! Bool
                                                if !hasAlreadyLiked {
                                                    global.likesGiven += 1
                                                    
                                                    let isFirstLike = json["isFirstLike"] as! Bool
                                                    if isFirstLike {
                                                        let fcm = json["fcm"] as! String
                                                        let badges = json["badges"] as! Int
                                                        global.sendNotification(body: "\(global.username) liked your byte: \"\(bytesPostData.content)\"", fcm: fcm, badges: badges, type: "byte")
                                                    }
                                                }
                                            }
                                        }
                                    }) {
                                        Image(systemName: "heart")
                                            .imageScale(.large)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .buttonStyle(BorderlessButtonStyle()) // Prevent button from being triggered when anywhere on view is clicked.
                                    .disabled(isUpdatingLike)
                                } else {
                                    Button(action: {
                                        isUpdatingLike = true
                                        bytesPostData.isLiked = false
                                        bytesPostData.likes -= 1
                                        
                                        let postString =
                                            "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                                            "password=\(global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                                            "byteId=\(bytesPostData.byteId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
                                        global.runPhp(script: "unlikeByte", postString: postString) { json in
                                            isUpdatingLike = false
                                            
                                            // User may have already unliked the byte on another screen.
                                            let hasAlreadyUnliked = json["hasAlreadyUnliked"] as! Bool
                                            if !hasAlreadyUnliked {
                                                global.likesGiven -= 1
                                            }
                                        }
                                    }) {
                                        Image(systemName: "heart.fill")
                                            .imageScale(.large)
                                            .foregroundColor(Color.pink)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .buttonStyle(BorderlessButtonStyle()) // Prevent button from being triggered when anywhere on view is clicked.
                                    .disabled(isUpdatingLike)
                                }
                            }
                            
                            Text("\(bytesPostData.likes)")
                            
                            Spacer()
                            
                            Button(action: {
                                showActionSheet = true
                            }) {
                                Image(systemName: "ellipsis")
                                    .imageScale(.large)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .buttonStyle(BorderlessButtonStyle()) // Prevent button from being triggered when anywhere on view is clicked.
                        }
                    }
                    .padding(.vertical)
                    
                    NavigationLinkEmpty(destination: BytesPostLikersView(byteId: bytesPostData.byteId), isActive: $mustVisitBytesPostLikers)
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
                    BuddiesProfileReportView(buddyId: bytesPostData.userId)
                        .environmentObject(globalObject)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .joinToSave:
                return Alert(title: Text("Join us to save this byte."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Join"), action: {
                    global.activeRootView = .join
                }))
            case .joinToLike:
                return Alert(title: Text("Join us to like this byte."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Join"), action: {
                    global.activeRootView = .join
                }))
            case .joinToBlock:
                return Alert(title: Text("Join us to block \(bytesPostData.username)."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Join"), action: {
                    global.activeRootView = .join
                }))
            case .joinToReport:
                return Alert(title: Text("Join us to report \(bytesPostData.username)."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Join"), action: {
                    global.activeRootView = .join
                }))
            case .block:
                return Alert(title: Text("Block Buddy"), message: Text("You will no longer receive messages or notifications from them. Their activity will also be hidden from your Buddies and Bytes tabs."), primaryButton: .default(Text("Cancel")), secondaryButton: .destructive(Text("Block"), action: {
                    global.block(buddyId: bytesPostData.userId, buddyUsername: bytesPostData.username)
                }))
            case .delete:
                return Alert(title: Text("Are you sure?"), message: Text("You cannot undo this action."), primaryButton: .default(Text("Cancel")
                ), secondaryButton: .destructive(Text("Delete"), action: {
                    let postString =
                        "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                        "password=\(global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                        "byteId=\(bytesPostData.byteId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
                    global.runPhp(script: "deleteByte", postString: postString) { json in
                        bytesPostData.isDeleted = true
                        
                        let hasAlreadyDeleted = json["hasAlreadyDeleted"] as! Bool
                        if !hasAlreadyDeleted {
                            global.bytesMade -= 1
                        }
                        
                        global.confirmationText = "Deleted"
                    }
                }))
            }
        }
    }
    
    func getActionSheet() -> ActionSheet {
        var buttons = [Alert.Button.default(Text("Copy")) {
            UIPasteboard.general.string = bytesPostData.content
            
            global.confirmationText = "Copied"
        }]
        
        if bytesPostData.likes > 0 {
            buttons += [Alert.Button.default(Text("Likes")) {
                mustVisitBytesPostLikers = true
            }]
        }
        
        if !global.savedBytes.contains(where: { $0.byteId == bytesPostData.byteId }) {
            buttons += [Alert.Button.default(Text("Save")) {
                if global.myId == "" {
                    activeAlert = .joinToSave
                } else {
                    global.saveByte(bytesPostData: bytesPostData)
                }
            }]
        } else {
            buttons += [Alert.Button.destructive(Text("Forget")) {
                global.forgetByte(byteId: bytesPostData.byteId)
            }]
        }
        
        if bytesPostData.userId != global.myId {
            buttons += [Alert.Button.destructive(Text("Block")) {
                if global.myId == "" {
                    activeAlert = .joinToBlock
                } else {
                    activeAlert = .block
                }
            }]
        }
        
        if bytesPostData.userId != global.myId {
            buttons += [Alert.Button.destructive(Text("Report")) {
                if global.myId == "" {
                    activeAlert = .joinToReport
                } else {
                    activeSheet = .buddiesProfileReport
                }
            }]
        }
        
        if bytesPostData.userId == global.myId {
            buttons += [Alert.Button.destructive(Text("Delete Byte")) {
                activeAlert = .delete
            }]
        }
        
        return ActionSheet(title: Text("Choose an Option"),
                           buttons: buttons + [Alert.Button.cancel()])
    }
}

struct BytesPostData: Identifiable, Codable {
    var id = UUID()
    var byteId: String
    var userId: String
    var username: String
    var isOnline: Bool
    var content: String
    var likes: Int
    var isLiked: Bool
    var postTime: Date
    var isDeleted = false
    
    init(byteId: String,
         userId: String,
         username: String,
         isOnline: Bool,
         content: String,
         likes: Int,
         isLiked: Bool,
         postTime: Date) {
        self.byteId = byteId
        self.userId = userId
        self.username = username
        self.isOnline = isOnline
        self.content = content
        self.likes = likes
        self.isLiked = isLiked
        self.postTime = postTime
    }
}
