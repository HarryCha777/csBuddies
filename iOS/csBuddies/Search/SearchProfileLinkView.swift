//
//  SearchProfileLinkView.swift
//  csBuddies
//
//  Created by Harry Cha on 6/3/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct SearchProfileLinkView: View {
    @EnvironmentObject var global: Global
    @Environment(\.colorScheme) var colorScheme
    
    let searchProfileLinkData: SearchProfileLinkData
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    if searchProfileLinkData.image == "" {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 75, height: 75)
                            .clipShape(Circle())
                    } else {
                        Image(uiImage: searchProfileLinkData.image.toUiImage())
                            .resizable()
                            .frame(width: 75, height: 75)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                        .frame(width: 10)

                    // Set spacing to 0 to preveng GitHub and LinkedIn logos from taking unnecessary vertical space.
                    VStack(spacing: 0) {
                        HStack {
                            Text("\(searchProfileLinkData.username)")
                                .bold()
                                .font(.system(size: 22))
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        }
                        HStack {
                            if searchProfileLinkData.genderIndex == 0 {
                                Text("\(global.genderOptions[searchProfileLinkData.genderIndex])")
                                    .foregroundColor(Color.blue) +
                                    Text(",")
                            } else if searchProfileLinkData.genderIndex == 1 {
                                Text("\(global.genderOptions[searchProfileLinkData.genderIndex])")
                                    .foregroundColor(Color(red: 255 / 255, green: 20 / 255, blue: 147 / 255)) + // pink
                                    Text(",")
                            } else if searchProfileLinkData.genderIndex == 2 ||
                                        searchProfileLinkData.genderIndex == 3 {
                                Text("\(global.genderOptions[searchProfileLinkData.genderIndex])")
                                    .foregroundColor(Color.gray) +
                                    Text(",")
                            } else {
                                Text("Unknown") +
                                    Text(",")
                            }
                            Text("\(searchProfileLinkData.birthday.toString(toFormat: "yyyy")[0] != "0" ? "\(searchProfileLinkData.birthday.toAge())" : "N/A")")
                            Spacer()
                            if searchProfileLinkData.hasGitHub {
                                Image("gitHubLogo")
                                    .resizable()
                                    .frame(width: 22, height: 22)
                                    .if(colorScheme == .dark) { content in
                                        content.colorInvert() // invert color on dark mode
                                    }
                            }
                            if searchProfileLinkData.hasLinkedIn {
                                Image("linkedInLogo")
                                    .resizable()
                                    .frame(width: 22, height: 22)
                            }
                        }
                    }
                }
                
                if searchProfileLinkData.intro.count != 0 {
                    HStack {
                        Text("\(searchProfileLinkData.intro.replacingOccurrences(of: "\n", with: " "))")
                            .lineLimit(3)
                        Spacer()
                    }
                }
            }
            
            if searchProfileLinkData.username != global.username {
                // Hide navigation link arrow by making invisible navigation link in ZStack.
                NavigationLink(destination: SearchProfileView(buddyUsername: searchProfileLinkData.username)) {
                    EmptyView()
                }
                .if(UIDevice.current.systemVersion[0...1] == "13") { content in
                    // This hides arrow in iOS 13, but disables link in iOS 14.
                    content.hidden()
                }
            }
        }
    }
}
