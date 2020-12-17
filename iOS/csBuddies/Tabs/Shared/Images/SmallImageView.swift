//
//  SmallImageView.swift
//  csBuddies
//
//  Created by Harry Cha on 10/30/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct SmallImageView: View {
    @EnvironmentObject var global: Global
    
    let userId: String
    let isOnline: Bool
    let size: CGFloat
    let myImage: String

    var body: some View {
        ZStack {
            if userId == global.myId {
                if myImage == "" {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: size, height: size)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                } else {
                    Image(uiImage: myImage.toUiImage())
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size, height: size)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
            } else {
                if global.smallImageCaches.object(forKey: userId as NSString) == nil {
                    ActivityIndicatorView()
                        .frame(width: size, height: size)
                        .onAppear {
                            if global.smallImageCaches.object(forKey: userId as NSString) == nil { // Check again since view updates are slow.
                                global.smallImageCaches.setObject(ImageCache(image: "loading", lastCacheTime: global.getUtcTime()), forKey: userId as NSString) // Don't fetch image again while it is loading.
                                let postString =
                                    "userId=\(userId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                                    "size=small"
                                global.runPhp(script: "getImage", postString: postString) { json in
                                    global.smallImageCaches.setObject(ImageCache(image: (json["image"] as! String), lastCacheTime: global.getUtcTime()), forKey: userId as NSString)
                                }
                            }
                        }
                } else if global.smallImageCaches.object(forKey: userId as NSString)!.image == "loading" {
                    ActivityIndicatorView()
                        .frame(width: size, height: size)
                } else if global.smallImageCaches.object(forKey: userId as NSString)!.image == "" {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: size, height: size)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                } else {
                    Image(uiImage: global.smallImageCaches.object(forKey: userId as NSString)!.image.toUiImage())
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size, height: size)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
            }
            
            VStack {
                Spacer()
                    .frame(width: size * 0.9)
                HStack {
                    Spacer()
                        .frame(width: size * 0.9)
                    Circle()
                        .frame(width: size / 4, height: size / 4)
                        .overlay(Circle().stroke(Color.white, lineWidth: size / 25))
                        .foregroundColor(Color.green)
                }
            }
            .opacity(isOnline ? 1 : 0) // Use opacity instead of if condition to place online and offline images on same position.
        }
        .frame(width: size, height: size) // Frame the entire view once more to ensure the view doesn't take up any unnecessary space, such as space below the view in ChatRoomMessageView.
    }
}
