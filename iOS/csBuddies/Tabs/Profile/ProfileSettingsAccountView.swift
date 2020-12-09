//
//  ProfileSettingsAccountView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/28/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase

struct ProfileSettingsAccountView: View {
    @EnvironmentObject var global: Global
    
    @State var activeSheet: Sheets?
    enum Sheets: Identifiable {
        var id: Int { self.hashValue }
        case
            profileSettingsAccountUsername
    }
    
    var body: some View {
        Form {
            Section(header: Text("Manage")) {
                NavigationLink(destination: ProfileSettingsAccountSavedUsersView()) {
                    Text("Saved Users")
                }
                
                NavigationLink(destination: ProfileSettingsAccountSavedBytesView()) {
                    Text("Saved Bytes")
                }
                
                NavigationLink(destination: ProfileSettingsAccountBlocksView()) {
                    Text("Blocked Users")
                }
            }
            
            /*Section(header: Text("Notifications")) {
                Toggle(isOn: $global.hasByteNotification) {
                    Text("Byte Like")
                }
                
                Toggle(isOn: $global.hasChatNotification) {
                    Text("New Message")
                }
            }*/

            Section(header: Text("User")) {
                Button(action: {
                    activeSheet = .profileSettingsAccountUsername
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
                    global.saveUserData()
                    global.resetUserData()
                
                    try! Auth.auth().signOut()
                    global.activeRootView = .loading
                }) {
                    Text("Log Out")
                        .foregroundColor(Color.red)
                }
                
                /*NavigationLink(destination: ProfileSettingsAccountDeleteView()) {
                    Text("Delete Account")
                        .foregroundColor(Color.red)
                }*/
            }
        }
        .navigationBarTitle("Account", displayMode: .inline)
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .profileSettingsAccountUsername:
                NavigationView {
                    ProfileSettingsAccountUsernameView()
                        .environmentObject(globalObject)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
        /*.onDisappear {
            let postString =
                "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "password=\(global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "hasByteNotification=\(global.hasByteNotification)&" +
                "hasChatNotification=\(global.hasChatNotification)"
            global.runPhp(script: "updateNotifications", postString: postString) { json in }
        }*/
    }
}
