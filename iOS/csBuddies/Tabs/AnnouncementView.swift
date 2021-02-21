//
//  AnnouncementView.swift
//  csBuddies
//
//  Created by Harry Cha on 1/31/21.
//  Copyright © 2021 Harry Cha. All rights reserved.
//

import SwiftUI

struct AnnouncementView: View {
    @EnvironmentObject var global: Global
    
    var body: some View {
        if global.announcementText != "" {
            HStack {
                if global.announcementLink == "" {
                    HStack {
                        Text(global.announcementText.replacingOccurrences(of: "\\n", with: "\n"))
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        Spacer()
                    }
                } else {
                    NavigationLink(destination:
                                            WebView(request: URLRequest(url: URL(string: global.announcementLink)!))
                                            .navigationBarTitle(global.announcementLink, displayMode: .inline)) {
                        HStack {
                            Text(global.announcementText.replacingOccurrences(of: "\\n", with: "\n"))
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                }
                
                Image(systemName: "xmark")
                    .imageScale(.large)
                    .foregroundColor(.white)
                    .onTapGesture {
                        global.announcementText = ""
                    }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.orange)
        }
    }
}

