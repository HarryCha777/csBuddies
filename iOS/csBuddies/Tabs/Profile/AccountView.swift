//
//  AccountView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/28/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase

struct AccountView: View {
    @EnvironmentObject var global: Global
    
    @State var activeSheet: Sheets?
    enum Sheets: Identifiable {
        var id: Int { self.hashValue }
        case
            requestNewUsername,
            signOut,
            disableAccount,
            deleteAccount
    }
    
    var body: some View {
        List {
            Section(header: Text("Manage")) {
                NavigationLink(destination: blockedBuddyIdsView()) {
                    Text("Blocked Users")
                }
            }
            
            Section(header: Text("Notifications")) {
                Toggle(isOn: $global.notifyLikes) {
                    Text("Likes on Bytes and Comments")
                }
                
                Toggle(isOn: $global.notifyComments) {
                    Text("Comments and Replies")
                }
                
                Toggle(isOn: $global.notifyMessages) {
                    Text("New Messages")
                }
            }
            
            Section(header: Text("User")) {
                Button(action: {
                    activeSheet = .requestNewUsername
                }) {
                    HStack {
                        Text("Request Username Change")
                        Spacer()
                    }
                    .background(Color.black.opacity(0.001)) // Expand button's tappable area to empty spaces.
                }
                .buttonStyle(PlainButtonStyle())
                
                /*NavigationLink(destination: ?) {
                 Text("Change Email")
                 }*/
                
                Button(action: {
                    activeSheet = .signOut
                }) {
                    HStack {
                        Text("Sign Out")
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .background(Color.black.opacity(0.001)) // Expand button's tappable area to empty spaces.
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    activeSheet = .disableAccount
                }) {
                    HStack {
                        Text("Disable Account")
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .background(Color.black.opacity(0.001)) // Expand button's tappable area to empty spaces.
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    activeSheet = .deleteAccount
                }) {
                    HStack {
                        Text("Delete Account")
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .background(Color.black.opacity(0.001)) // Expand button's tappable area to empty spaces.
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Account", displayMode: .inline)
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .requestNewUsername:
                NavigationView {
                    RequestNewUsernameView()
                        .environmentObject(globalObject)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            case .signOut:
                NavigationView {
                    SignOutView()
                        .environmentObject(globalObject)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            case .disableAccount:
                NavigationView {
                    DisableAccountView()
                        .environmentObject(globalObject)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            case .deleteAccount:
                NavigationView {
                    DeleteAccountView()
                        .environmentObject(globalObject)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }
}
