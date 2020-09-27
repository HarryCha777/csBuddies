//
//  AppView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/16/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct AppView: View {
    @EnvironmentObject var global: Global
    
    @ObservedObject private var keyboardDetector = KeyboardDetector()

    var body: some View {
        Group {
            if global.isCheckingUser {
                CheckUserView()
            } else {
                if global.isNewUser {
                    if global.isSelectingInterests {
                        SelectInterestsView()
                    } else if global.isSettingProfile {
                        SetProfileView()
                    } else {
                        TypeIntroView()
                    }
                } else {
                    if global.mustUpdate {
                        MustUpdateView()
                    } else if global.isBanned {
                        BannedView()
                    } else {
                        GeometryReader { geometry in
                            ZStack(alignment: .bottomLeading) {
                                TabView(selection: self.$global.tabIndex) {
                                    SearchView()
                                        .tabItem {
                                            Image(systemName: "magnifyingglass")
                                                .imageScale(.large)
                                            Text("Search")
                                    }
                                    .tag(0)
                                    
                                    ChatView()
                                        .tabItem {
                                            Image(systemName: "text.bubble")
                                                .imageScale(.large)
                                            Text("Chat")
                                    }
                                    .tag(1)
                                    
                                    ProfileView()
                                        .tabItem {
                                            Image(systemName: "person")
                                                .imageScale(.large)
                                            Text("Profile")
                                    }
                                    .tag(2)
                                    
                                    SettingsView()
                                        .tabItem {
                                            Image(systemName: "gear")
                                                .imageScale(.large)
                                            Text("Settings")
                                    }
                                    .tag(3)
                                }
                                
                                if !keyboardDetector.isKeyboardShown {
                                    ZStack {
                                        Circle()
                                            .foregroundColor(.red)
                                    
                                        if self.global.getUnreadCounter() <= 99 {
                                            Text("\(self.global.getUnreadCounter())")
                                                .foregroundColor(.white)
                                                .font(Font.system(size: 10))
                                        } else {
                                            Text("99+")
                                                .foregroundColor(.white)
                                                .font(Font.system(size: 10))
                                        }
                                    }
                                    .frame(width: 20, height: 20)
                                    // Offset x: (tab's index * 2 - 1) * (geometry.size.width / (total number of tabs * 2)
                                    .offset(x: (2 * 2 - 1) * (geometry.size.width / (4 * 2)), y: -30)
                                    .opacity(self.global.getUnreadCounter() == 0 ? 0 : 1)
                                }
                            }
                        }
                        
                        // Make invisible view to handle navigation to Chat Room View when needed.
                        if self.global.mustVisitChatRoom {
                            Spacer()
                                .frame(height: 0)
                                .onAppear {
                                    self.global.tabIndex = 1
                            }
                        }
                    }
                }
            }
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
