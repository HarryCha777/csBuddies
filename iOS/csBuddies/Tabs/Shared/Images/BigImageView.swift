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
    @State private var isLoading = true

    var body: some View {
        VStack {
            if isLoading {
                LottieView(name: "load", size: 300, mustLoop: true)
                    .onAppear {
                        if global.bigImageCaches.object(forKey: userId as NSString) != nil {
                            bigImage = global.bigImageCaches.object(forKey: userId as NSString)!.image
                            isLoading = false
                        } else {
                            let postString =
                                "userId=\(userId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                                "size=big"
                            global.runPhp(script: "getImage", postString: postString) { json in
                                bigImage = (json["image"] as! String)
                                global.bigImageCaches.setObject(ImageCache(image: bigImage, lastCacheTime: global.getUtcTime()), forKey: userId as NSString)
                                isLoading = false
                            }
                        }
                    }
            } else if bigImage == "" {
                Text("No Image")
                    .font(.title)
                    .foregroundColor(Color.white)
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
    }
}
