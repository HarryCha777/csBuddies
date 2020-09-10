//
//  ChatRoomMenuView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/28/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase

struct ChatRoomMenu: View {
    @EnvironmentObject var global: Global
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentation
    
    let buddyUsername: String
    let isMenuOpen: Bool
    let onMenuClose: () -> Void
    let screenWidth = UIScreen.main.bounds.size.width
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                EmptyView()
            }
            .background(Color.black.opacity(0.3)) // make screen's background black
            .opacity(self.isMenuOpen ? 1.0: 0.0) // reset screen's background when menu is closed
            .animation(Animation.easeIn.delay(0.25)) // delay changing screen's background
            .onTapGesture {
                self.onMenuClose()
            }
            
            HStack {
                Form {
                    ZStack(alignment: .leading) {
                        Text("View User")
                            .foregroundColor(Color.blue)

                        // Hide navigation link arrow by making invisible navigation link in ZStack.
                        NavigationLink(destination: SearchProfileView(buddyUsername: self.buddyUsername)) {
                            EmptyView()
                        }
                        .hidden()
                    }

                    if !global.blockedList.contains(self.buddyUsername) {
                        Button(action: {
                            self.global.block(buddyUsername: self.buddyUsername)
                        }) {
                            Text("Block User")
                                .foregroundColor(Color.red)
                        }
                    } else {
                        Button(action: {
                            self.global.unblock(buddyUsername: self.buddyUsername)
                        }) {
                            Text("Unblock User")
                                .foregroundColor(Color.blue)
                        }
                    }
                    
                    ZStack(alignment: .leading) {
                        Text("Report User")
                            .foregroundColor(Color.red)
                        
                        // Hide navigation link arrow by making invisible navigation link in ZStack.
                        NavigationLink(destination: SearchProfileReportView(buddyUsername: self.buddyUsername)) {
                            EmptyView()
                        }
                        .hidden()
                    }

                    Button(action: {
                        self.presentation.wrappedValue.dismiss()
                        
                        if self.global.chatHistory[self.buddyUsername] != nil {
                            self.global.deleteChatRoom(buddyUsername: self.buddyUsername)
                        }
                    }) {
                        Text("Delete Chat Room")
                            .foregroundColor(Color.red)
                    }
                }
                .background(Color.white)
                .frame(width: screenWidth * 0.7) // position side menu appropriately based on screen width
                .offset(x: CGFloat(self.isMenuOpen ? screenWidth * 0.3: screenWidth)) // move side menu if it is opened
                .animation(.default) // animate sliding in side menu
                .introspectTableView { tableView in // change tableView only for this view
                    tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude)) // remove extra space at top
                }

                Spacer()
            }
        }
    }
}
