//
//  ChatRoomView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/28/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase

struct ChatRoomView: View {
    @EnvironmentObject var global: Global
    @Environment(\.presentationMode) var presentation
    
    let buddyUsername: String
    
    @State var isMenuOpen = false
    @State private var modifiedListener: ListenerRegistration?
    
    var body: some View {
        ZStack {
            VStack {
                ChatRoomListView(buddyUsername: buddyUsername)
                Spacer()
                ChatRoomInputView(buddyUsername: buddyUsername)
            }

            ChatRoomMenu(buddyUsername: buddyUsername,
                         isMenuOpen: self.isMenuOpen,
                         onMenuClose: {
                            self.isMenuOpen.toggle()
                         })
        }
        .navigationBarTitle("\(buddyUsername)", displayMode: .inline)
        .navigationBarItems(trailing:
            Button(action: {
                self.isMenuOpen.toggle()
            }) {
                Image(systemName: "ellipsis.circle")
                    .imageScale(.large)
            }
        )
        .if(UIDevice.current.systemVersion[0...1] == "13") { content in
            content.modifier(AdaptsToKeyboard())
        }
        .animation(.easeOut(duration: 0.16))
        .onAppear {
            self.markAllRead()
            self.global.mustVisitChatRoom = false
            self.global.currentBuddyUsername = self.buddyUsername
            self.listenToChangedMessage()
        }
        .onDisappear {
            self.global.currentBuddyUsername = ""
            self.modifiedListener!.remove()
        }
    }
    
    func markAllRead() {
        if global.chatHistory[buddyUsername] != nil {
            for index in global.chatHistory[buddyUsername]!.indices {
                if global.chatHistory[buddyUsername]![index].sender != global.username &&
                    !global.chatHistory[buddyUsername]![index].isRead {
                    global.chatHistory[buddyUsername]![index].isRead = true
                    global.mustUpdateBadges = true
                }
            }
        }
        
        global.db.collection("messages")
            .whereField("sender", isEqualTo: self.buddyUsername)
            .whereField("receiver", isEqualTo: self.global.username)
            .whereField("isRead", isEqualTo: false)
            .whereField("isDeleted", isEqualTo: false)
            .getDocuments { (snapshot, error) in
                for document in snapshot!.documents {
                    document.reference
                        .setData(["isRead": true], merge: true)
                }
        }
    }

    func listenToChangedMessage() {
        var lastRead = Date(timeIntervalSince1970: 0)
        if global.chatHistory[buddyUsername] != nil {
            for chatRoomMessageData in global.chatHistory[buddyUsername]! {
                if chatRoomMessageData.sender == global.username &&
                    chatRoomMessageData.isRead &&
                    lastRead < chatRoomMessageData.sentTime {
                    lastRead = chatRoomMessageData.sentTime
                }
            }
        }
        
        self.modifiedListener = global.db.collection("messages")
            .whereField("sender", isEqualTo: self.global.username)
            .whereField("receiver", isEqualTo: self.buddyUsername)
            .whereField("sentTime", isGreaterThanOrEqualTo: lastRead)
            .addSnapshotListener { (snapshot, error) in
                
                snapshot!
                    .documentChanges
                    .forEach { documentChange in
                        if (documentChange.type == .modified) {
                            self.global.chatHistory[self.buddyUsername] = self.global.chatHistory[self.buddyUsername].map { (eachChatRoomMessageDataList) -> [ChatRoomMessageData] in
                                var chatRoomMessageDataList = eachChatRoomMessageDataList
                                for index in chatRoomMessageDataList.indices {
                                    if chatRoomMessageDataList[index].id == documentChange.document.documentID {
                                        chatRoomMessageDataList[index].isRead = documentChange.document.get("isRead") as! Bool
                                        chatRoomMessageDataList[index].isDeleted = documentChange.document.get("isDeleted") as! Bool
                                    }
                                }
                                return chatRoomMessageDataList
                            }
                        }
                }
        }
    }
}

struct ChatRoomView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomView(buddyUsername: "")
    }
}
