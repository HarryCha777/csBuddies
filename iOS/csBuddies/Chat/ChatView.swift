//
//  ChatView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/28/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase

struct ChatView: View {
    @EnvironmentObject var global: Global

    @State private var sortedBuddyUsernames = [String]()
    @State private var showPrepermissionAlert = false
    
    var body: some View {
        NavigationView {
            if global.username == "" {
                VStack {
                    Text("You must sign up to text other users.")
                    Spacer()
                        .frame(height: 50)
                    Text("Sign up only takes a minute, and we never ask for your email, phone number, or password.")
                    Spacer()
                        .frame(height: 10)
                    Button(action: {
                        self.global.viewId = ViewId(id: .signUp)
                        self.global.signUpId = SignUpId(id: .selectInterests)
                    }) {
                        Text("Click here to sign up!")
                    }
                    Spacer()
                }
                .padding()
                .navigationBarTitle("Chat")
            } else {
                List {
                    if UIDevice.current.systemVersion[0...1] == "13" {
                        // Make invisible view to handle navigation to Chat Room when needed.
                        if global.mustVisitChatRoom {
                            NavigationLink(destination: ChatRoomView(buddyUsername: global.notificationBuddyUsername),
                                           isActive: $global.mustVisitChatRoom) {
                                            EmptyView()
                            }
                        }
                    }
                
                    if UIDevice.current.systemVersion[0...1] == "13" {
                        ForEach(sortedBuddyUsernames, id: \.self) { buddyUsername in
                            ChatRoomLinkView(buddyUsername: buddyUsername)
                        }
                        .onDelete(perform: deleteChatRoom)
                    } else {
                        ForEach(global.chatHistory.sorted(by: { $0.value.last!.sentTime > $1.value.last!.sentTime }), id: \.key) { key, value in
                            ChatRoomLinkView(buddyUsername: key)
                        }
                        .onDelete(perform: deleteChatRoom)
                    }

                    if global.chatHistory.count == 0 {
                        Text("You are not in any chat room.")
                    }
                }
                .roundCorners()
                .navigationBarTitle("Chat")
                .navigationBarItems(trailing: EditButton())
                .alert(isPresented: $showPrepermissionAlert) {
                        Alert(title: Text("Get notified when someone texts you!"),
                                     message: Text("Would you like to receive a notification when you receive text messages?"),
                                     primaryButton: .destructive(Text("Not Now")),
                                     secondaryButton: .default(Text("Notify Me"), action: {
                                        self.global.requestPermission()
                                     }))
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            if global.username != "" {
                if UIDevice.current.systemVersion[0...1] == "13" {
                    // Create a sorted array instead of simply looping over the sorted chatHistory dictionary in ForEach.
                    // Otherwise, whenever the order changes (due to sending, receiving, or hiding messages), the user will be kicked out of the current chat room.
                    // But this is only in iOS 13 since user doesn't get kicked out in iOS 14, so there's no need for sortedBuddyUsernames in iOS 14.
                    self.sortedBuddyUsernames = self.global.chatHistory.sorted(by: { $0.value.last!.sentTime > $1.value.last!.sentTime }).map({ $0.key })
                }
                
                self.global.hasDeterminedPermission() { hasDeterminedPermission in
                    if !hasDeterminedPermission && !Calendar.current.isDate(self.global.getUtcTime(), inSameDayAs: self.global.lastShownPrepermissionAlertInChatView) {
                        DispatchQueue.main.async {
                            self.global.lastShownPrepermissionAlertInChatView = self.global.getUtcTime()
                            self.showPrepermissionAlert = true
                        }
                    }
                }
            }
        }
    }

    func deleteChatRoom(at offsets: IndexSet) {
        global.mustUpdateBadges = true
        global.deleteChatRoom(buddyUsername: global.chatHistory.sorted(by: { $0.value.last!.sentTime > $1.value.last!.sentTime })[offsets.first!].key)
        sortedBuddyUsernames = self.global.chatHistory.sorted(by: { $0.value.last!.sentTime > $1.value.last!.sentTime }).map({ $0.key })
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
