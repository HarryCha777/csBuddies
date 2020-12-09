//
//  TabsView.swift
//  csBuddies
//
//  Created by Harry Cha on 10/2/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct TabsView: View {
    @EnvironmentObject var global: Global
    
    @ObservedObject private var keyboardDetector = KeyboardDetector()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                TabView(selection: $global.tabIndex) {
                    NavigationView {
                        ZStack {
                            BuddiesView()
                            NotificationView()
                        }
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .tabItem {
                        Image(systemName: "person.3")
                            .font(.title)
                        Text("Buddies")
                    }
                    .tag(0)
                    
                    NavigationView {
                        ZStack {
                            BytesView()
                            NotificationView()
                        }
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .tabItem {
                        Image(systemName: "pencil.circle")
                            .font(.title)
                        Text("Bytes")
                    }
                    .tag(1)
                    
                    NavigationView {
                        ZStack {
                            ChatView()
                            NotificationView()
                        }
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .tabItem {
                        Image(systemName: "text.bubble")
                            .font(.title)
                        Text("Chat")
                    }
                    .tag(2)
                    
                    NavigationView {
                        ZStack {
                            ProfileView()
                            NotificationView()
                        }
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .tabItem {
                        Image(systemName: "person")
                            .font(.title)
                        Text("Profile")
                    }
                    .tag(3)
                }
                
                if global.isKeyboardHidden &&
                    global.getUnreadCounter() > 0 {
                    ZStack {
                        Circle()
                            .foregroundColor(.red)
                    
                        if global.getUnreadCounter() <= 99 {
                            Text("\(global.getUnreadCounter())")
                                .foregroundColor(.white)
                                .font(Font.system(size: 10))
                        } else {
                            Text("99+")
                                .foregroundColor(.white)
                                .font(Font.system(size: 10))
                        }
                    }
                    .frame(width: 20, height: 20)
                    // Offset x: (tab index * 2 - 1) * (geometry.size.width / (number of tabs * 2).
                    .offset(x: (3 * 2 - 1) * (geometry.size.width / (4 * 2)), y: -30)
                }
            }
        }
    }
}

struct TabsView_Previews: PreviewProvider {
    static var previews: some View {
        TabsView()
    }
}
