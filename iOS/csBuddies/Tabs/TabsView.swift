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
        ZStack {
            GeometryReader { geometry in
                ZStack(alignment: .bottomLeading) {
                    TabView(selection: $global.tab) {
                        NavigationView {
                            BuddiesView()
                                .environmentObject(globalObject)
                                .overlay(
                                    VStack {
                                        Spacer()
                                        AnnouncementView()
                                    }
                                )
                        }
                        .navigationViewStyle(StackNavigationViewStyle())
                        .tabItem {
                            Image(systemName: "person.3")
                                .font(.title)
                            Text("Buddies")
                        }
                        .tag(0)
                        
                        NavigationView {
                            BytesView()
                                .environmentObject(globalObject)
                        }
                        .navigationViewStyle(StackNavigationViewStyle())
                        .tabItem {
                            Image(systemName: "pencil.circle")
                                .font(.title)
                            Text("Bytes")
                        }
                        .tag(1)
                        
                        NavigationView {
                            ChatView()
                                .environmentObject(globalObject)
                        }
                        .navigationViewStyle(StackNavigationViewStyle())
                        .tabItem {
                            Image(systemName: "text.bubble")
                                .font(.title)
                            Text("Chat")
                        }
                        .tag(2)
                        
                        NavigationView {
                            ProfileView()
                                .environmentObject(globalObject)
                        }
                        .navigationViewStyle(StackNavigationViewStyle())
                        .tabItem {
                            Image(systemName: "person")
                                .font(.title)
                            Text("Profile")
                        }
                        .tag(3)
                    }
                    
                    if global.isKeyboardHidden {
                        if global.getUnreadNotificationsCounter() > 0 {
                            ZStack {
                                Circle()
                                    .foregroundColor(.red)
                                
                                if global.getUnreadNotificationsCounter() <= 99 {
                                    Text("\(global.getUnreadNotificationsCounter())")
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
                            .offset(x: (2 * 2 - 1) * (geometry.size.width / (4 * 2)), y: -30)
                        }
                        
                        if global.getUnreadMessagesCounter() > 0 {
                            ZStack {
                                Circle()
                                    .foregroundColor(.red)
                                
                                if global.getUnreadMessagesCounter() <= 99 {
                                    Text("\(global.getUnreadMessagesCounter())")
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
            .disabledOnLoad(isLoading: global.confirmationText != "", showLoading: false)
            
            ConfirmationView()
        }
        .alert(item: $global.activeAlert) { alert in
            switch alert {
            case .cannotBlockAdmin:
                return Alert(title: Text("The User is an Admin"), message: Text("You cannot block an admin. For any questions or feedback, please contact us instead."), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct TabsView_Previews: PreviewProvider {
    static var previews: some View {
        TabsView()
    }
}
