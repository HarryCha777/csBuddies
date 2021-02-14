//
//  BigImageView.swift
//  csBuddies
//
//  Created by Harry Cha on 10/30/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct BigImageView: View {
    @EnvironmentObject var global: Global
    @Environment(\.presentationMode) var presentation
    
    let userId: String
    @State private var bigImage = ""
    @State private var isLoading = false

    var body: some View {
        VStack {
            if isLoading {
                LottieView(name: "load", size: 300, mustLoop: true)
            } else if bigImage == "" {
                Text("No Image")
                    .font(.title)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            } else {
                Image(uiImage: bigImage.toUiImage())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .pinchToZoom()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
            presentation.wrappedValue.dismiss()
        }
        .onAppear {
            if isLoading {
                return
            }
            isLoading = true
            
            if global.bigImageCache.object(forKey: userId as NSString) != nil {
                bigImage = global.bigImageCache.object(forKey: userId as NSString)!.image
                isLoading = false
            } else {
                let postString =
                    "userId=\(userId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                    "size=big"
                global.runPhp(script: "getImage", postString: postString) { json in
                    bigImage = (json["image"] as! String)
                    global.bigImageCache.setObject(ImageCache(image: bigImage, lastCachedAt: global.getUtcTime()), forKey: userId as NSString)
                    isLoading = false
                }
            }
        }
    }
}
