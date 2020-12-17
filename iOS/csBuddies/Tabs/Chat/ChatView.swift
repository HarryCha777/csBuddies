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

    @State private var hasRunOnAppear = false
    @State private var isRefreshing = false
    
    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            prepermission
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
                        global.blueButton(title: "Get Magic Link")
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
                                    global.blueButton(title: "Turn on Notification")
                                }))
                    } else {
                        List {
                            ForEach(global.chatData.sorted(by: { min($0.value.messages.count, $1.value.messages.count) == 0 ? false : $0.value.messages.last!.sendTime > $1.value.messages.last!.sendTime }), id: \.key) { key, value in
                                ChatRoomPreviewView(buddyId: key, buddyUsername: global.chatData[key]!.username, isOnline: global.chatData[key]!.isOnline)
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
                        .pullToRefresh(isShowing: $isRefreshing) {
                            getChatIsOnline()
                        }
                        .toolbar {
                            ToolbarItem(placement: .primaryAction) {
                                EditButton()
                            }
                        }
                        .onAppear {
                            // Code below may prevent NotificationView from working in Chat tab, so fix it.
                            if !hasRunOnAppear && global.myId != "" {
                                hasRunOnAppear = true
                                getChatIsOnline()
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
            }
        }
    }
    
    func deleteChatRoom(at offsets: IndexSet) {
        let buddyId = global.chatData.sorted(by: { $0.value.messages.last!.sendTime > $1.value.messages.last!.sendTime })[offsets.first!].key
        global.chatData[buddyId] = nil
        
        global.updateBadges()
        DispatchQueue.main.async { // Prevent error on swipe to delete: Simultaneous accesses to 0x10b1af298, but modification requires exclusive access.
            global.confirmationText = "Cleared"
        }
    }
    
    func getChatIsOnline() {
        // Below is a redundant call since the chat rooms may have been deleted.
        let postString =
            "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "password=\(global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
        global.runPhp(script: "getChatIsOnline", postString: postString) { json in
            if json.count > 0 {
                for i in 1...json.count {
                    let row = json[String(i)] as! NSDictionary
                    let buddyId = row["buddyId"] as! String
                    let isOnline = global.isOnline(lastVisitTimeAny: row["lastVisitTime"])
                    if global.chatData[buddyId] != nil {
                        global.chatData[buddyId]!.isOnline = isOnline
                    }
                }
            }
            isRefreshing = false
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
