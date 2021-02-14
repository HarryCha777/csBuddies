//
//  ChatView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/28/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var global: Global

    @State private var mustGetChatIsOnline = true
    @State private var chatRoomIndex = 0
    
    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            prepermission,
            clear
    }
    
    var body: some View {
        VStack {
            if global.myId == "" {
                SimpleView(
                    lottieView: LottieView(name: "chat", size: 250, padding: 25),
                    subtitle: "Join us to text other users. You only need an email, and we'll send you a magic link!",
                    bottomView: AnyView(Button(action: {
                        global.activeRootView = .join
                    }) {
                        ColoredButton(title: "Get Magic Link")
                    }))
            } else {
                VStack {
                    if global.chatData.count == 0 {
                        SimpleView(
                            lottieView: LottieView(name: "chat", size: 250, padding: 25),
                            subtitle: "You are not in any chat room.",
                            bottomView: global.hasAskedNotification ? nil :
                                AnyView(Button(action: {
                                    activeAlert = .prepermission
                                }) {
                                    ColoredButton(title: "Turn on Notification")
                                }))
                    } else {
                        List {
                            ForEach(global.chatData.sorted(by: { $0.value.messages.last!.sentAt > $1.value.messages.last!.sentAt }), id: \.key) { key, value in
                                ChatRoomPreviewView(chatRoomPreviewData: ChatRoomPreviewData(buddyId: key, buddyUsername: global.chatData[key]!.username, lastVisitedAt: global.chatData[key]!.lastVisitedAt))
                            }
                            .onDelete(perform: deleteChatRoom)

                            if !global.hasAskedNotification {
                                Button(action: {
                                    activeAlert = .prepermission
                                }) {
                                    Text("Turn on Notification")
                                }
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                        .refresh(isRefreshing: $mustGetChatIsOnline, isRefreshingBool: mustGetChatIsOnline) {
                            getChatIsOnline()
                        }
                        .toolbar {
                            ToolbarItem(placement: .primaryAction) {
                                EditButton()
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Chat")
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .prepermission:
                return Alert(title: Text("Get notified when someone texts you!"),
                      message: Text("Would you like to receive a notification when you receive text messages?"),
                      primaryButton: .destructive(Text("Not Now")),
                      secondaryButton: .default(Text("Notify Me"), action: {
                        global.askNotification()
                      }))
            case .clear:
                return Alert(title: Text("Are you sure?"), message: Text("You cannot undo this action."), primaryButton: .default(Text("Cancel")
                ), secondaryButton: .destructive(Text("Clear"), action: {
                    let buddyId = global.chatData.sorted(by: { $0.value.messages.last!.sentAt > $1.value.messages.last!.sentAt })[chatRoomIndex].key
                    global.chatData[buddyId] = nil
                    global.updateBadges()
                    
                    global.confirmationText = "Cleared"
                }))
            }
        }
    }
    
    func deleteChatRoom(at offsets: IndexSet) {
        chatRoomIndex = offsets.first!
        activeAlert = .clear
    }
    
    func getChatIsOnline() {
        if global.myId == "" {
            return
        }
        
        // Below is a .redundant call since the chat rooms may have been deleted.
        global.firebaseUser!.getIDToken(completion: { (token, error) in
            let postString =
                "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
            global.runPhp(script: "getChatIsOnline", postString: postString) { json in
                if json.count > 0 {
                    for i in 1...json.count {
                        let row = json[String(i)] as! NSDictionary
                        let buddyId = row["buddyId"] as! String
                        if global.chatData[buddyId] != nil {
                            global.chatData[buddyId]!.lastVisitedAt = (row["lastVisitedAt"] as! String).toDate()
                        }
                    }
                }
                mustGetChatIsOnline = false
            }
        })
    }
}
