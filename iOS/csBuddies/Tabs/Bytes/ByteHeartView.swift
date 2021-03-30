//
//  ByteHeartView.swift
//  csBuddies
//
//  Created by Harry Cha on 1/15/21.
//  Copyright © 2021 Harry Cha. All rights reserved.
//

import SwiftUI

struct ByteHeartView: View {
    @EnvironmentObject var global: Global
    
    let byteId: String
    // global.bytes[byteId] must be set in advance.
    
    @State private var isUpdatingLike = false
    
    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            joinToLike
    }
    
    var body: some View {
        VStack {
            // Do not let users like their own content since that will clutter up the list of content they liked with list of content they made.
            if global.myId == global.bytes[byteId]!.userId {
                Image(systemName: "heart.fill")
                    .foregroundColor(.gray)
            } else if isUpdatingLike && global.bytes[byteId]!.isLiked {
                LottieView(name: "like", size: 75)
                    .frame(width: 21, height: 16)
            } else if !global.bytes[byteId]!.isLiked {
                Button(action: {
                    if global.myId == "" {
                        activeAlert = .joinToLike
                    } else if !isUpdatingLike { // Use if condition since .disabled(isUpdatingLike) does not work for an unknown reason.
                        isUpdatingLike = true
                        global.bytes[byteId]!.isLiked = true
                        global.bytes[byteId]!.likes += 1
                        
                        global.firebaseUser!.getIDToken(completion: { (token, error) in
                            let postString =
                                "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                                "byteId=\(byteId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
                            global.runHttp(script: "likeByte", postString: postString) { json in
                                isUpdatingLike = false
                                
                                // User may have already liked the byte on another screen.
                                let isLiked = json["isLiked"] as! Bool
                                if !isLiked {
                                    global.byteLikesGiven += 1
                                }
                            }
                        })
                    }
                }) {
                    Image(systemName: "heart")
                }
                .buttonStyle(PlainButtonStyle())
                .buttonStyle(BorderlessButtonStyle()) // Prevent button from being triggered when anywhere on view is clicked.
            } else {
                Button(action: {
                    if !isUpdatingLike {// Use if condition since .disabled(isUpdatingLike) does not work for an unknown reason.
                        isUpdatingLike = true
                        global.bytes[byteId]!.isLiked = false
                        global.bytes[byteId]!.likes -= 1
                        
                        global.firebaseUser!.getIDToken(completion: { (token, error) in
                            let postString =
                                "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                                "byteId=\(byteId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
                            global.runHttp(script: "unlikeByte", postString: postString) { json in
                                isUpdatingLike = false
                                
                                // User may have already unliked the byte on another screen.
                                let isUnliked = json["isUnliked"] as! Bool
                                if !isUnliked {
                                    global.byteLikesGiven -= 1
                                }
                            }
                        })
                    }
                }) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.pink)
                }
                .buttonStyle(PlainButtonStyle())
                .buttonStyle(BorderlessButtonStyle()) // Prevent button from being triggered when anywhere on view is clicked.
            }
        }
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .joinToLike:
                return Alert(title: Text("Join us to like this byte."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Join"), action: {
                    global.activeRootView = .join
                }))
            }
        }
    }
}
