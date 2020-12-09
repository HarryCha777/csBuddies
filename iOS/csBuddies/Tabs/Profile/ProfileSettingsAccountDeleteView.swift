//
//  ProfileSettingsAccountDeleteView.swift
//  csBuddies
//
//  Created by Harry Cha on 11/18/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

/*import SwiftUI
import Firebase

struct ProfileSettingsAccountDeleteView: View {
    @EnvironmentObject var global: Global
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Form {
            Text("Are you sure?")
                .font(.title)
            
            Text("If you delete your account, your chat history and profile will be inaccessible.")
            
            // Maybe ask why user wants to delete account.
            
            // Show a loading screen while account is being deleted so user cannot click delete more than once.

            Section(header: Text("")) {
                Link(destination: URL(string: "mailto:csbuddiesapp@gmail.com")!) {
                    HStack {
                        Text("Contact Us")
                        Spacer()
                    }
                    .background(Color.black.opacity(0.001)) // Expand button's tappable area to empty spaces.
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    global.saveUserData()
                    global.resetUserData()
                    
                    let user = Auth.auth().currentUser
                    user?.delete { error in
                        global.activeRootView = .loading
                    }
                }) {
                    Text("Delete Account")
                        .foregroundColor(Color.red)
                }
            }
        }
        .navigationBarTitle("Delete Account", displayMode: .inline)
    }
}*/
