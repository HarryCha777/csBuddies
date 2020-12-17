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
    
    @State private var isSigningOut = false
    
    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            signOut,
            tooSoon
    }
    
    @State var activeSheet: Sheets?
    enum Sheets: Identifiable {
        var id: Int { self.hashValue }
        case
            profileSettingsAccountUsername
    }
    
    var body: some View {
        ZStack {
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
                
                Section(header: Text("Notifications")) {
                    Toggle(isOn: $global.hasByteNotification) {
                        Text("Byte Like")
                    }
                    
                    Toggle(isOn: $global.hasChatNotification) {
                        Text("New Message")
                    }
                }
                
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
                        activeAlert = .signOut
                    }) {
                        Text("Sign Out")
                            .foregroundColor(Color.red)
                    }
                    
                    /*NavigationLink(destination: ProfileSettingsAccountDeleteView()) {
                     Text("Delete Account")
                     .foregroundColor(Color.red)
                     }*/
                }
            }
            .disabled(isSigningOut)
            .opacity(isSigningOut ? 0.3 : 1)
            
            if isSigningOut {
                LottieView(name: "load", size: 300, mustLoop: true)
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
        .alert(item: $activeAlert) { alert in
            DispatchQueue.main.async {
                isSigningOut = false
            }
            
            switch alert {
            case .signOut:
                return Alert(title: Text("Are you sure?"), message: Text("You will not receive new message notifications while you are signed out."), primaryButton: .default(Text("Cancel")
                ), secondaryButton: .destructive(Text("Sign Out"), action: {
                    isSigningOut = true
                    signOut()
                }))
            case .tooSoon:
                return Alert(title: Text("Too Soon"), message: Text("To prevent spam, you can sign out only after waiting for one week since signing in."), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func signOut() {
        let postString =
            "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "password=\(global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
        global.runPhp(script: "signOut", postString: postString) { json in
            if json["isTooSoon"] != nil {
                activeAlert = .tooSoon
                return
            }
            
            global.resetUserData()

            try! Auth.auth().signOut()
            global.activeRootView = .loading
        }
    }
}
