//
//  UserProfileView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/20/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var global: Global
    
    var body: some View {
        if global.myId == "" {
            SimpleView(
                lottieView: LottieView(name: "team", size: 300, mustLoop: true),
                subtitle: "Join us to build your profile. You only need an email, and we'll send you a magic link!",
                bottomView: AnyView(Button(action: {
                    global.activeRootView = .join
                }) {
                    ColoredButton(title: "Get Magic Link")
                }))
                .navigationBarTitle("Profile")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        HStack { // Having at least 2 views inside HStack is necessary to make Image larger.
                            Spacer()
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gear")
                                    .font(.largeTitle)
                            }
                        }
                    }
                }
        } else {
            UserView(userId: global.myId, isProfileTab: true)
        }
    }
}
