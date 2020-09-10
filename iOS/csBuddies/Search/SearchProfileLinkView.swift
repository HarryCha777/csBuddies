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
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } else {
                        Image(uiImage: searchProfileLinkData.image.toUiImage())
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    }
                    
                    // Set spacing to 0 to preveng GitHub and LinkedIn logos from taking unnecessary vertical space.
                    VStack(spacing: 0) {
                        HStack {
                            Text("\(searchProfileLinkData.username)")
                                .bold()
                                .font(.system(size: 22))
                                .lineLimit(1)
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
                            } else if searchProfileLinkData.genderIndex == 2 {
                                Text("\(global.genderOptions[searchProfileLinkData.genderIndex])")
                                    .foregroundColor(Color.gray) +
                                    Text(",")
                            } else {
                                Text("Unknown") +
                                    Text(",")
                            }
                            Text("\(searchProfileLinkData.birthday.toAge())")
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
                
                if searchProfileLinkData.shortInterests.count != 0 {
                    HStack {
                        Text("\(searchProfileLinkData.shortInterests.toReadableInterests())")
                            .lineLimit(1)
                        Spacer()
                    }
                }
                if searchProfileLinkData.shortIntro.count != 0 {
                    HStack {
                        Text("\(searchProfileLinkData.shortIntro.replacingOccurrences(of: "\n", with: " "))")
                            .lineLimit(1)
                        Spacer()
                    }
                }
            }
    
            // Hide navigation link arrow by making invisible navigation link in ZStack.
            NavigationLink(destination: SearchProfileView(buddyUsername: searchProfileLinkData.username)) {
                EmptyView()
            }
            .hidden()
        }
    }
}
