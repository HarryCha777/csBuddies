//
//  ProfileSettingsView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/28/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase

struct ProfileSettingsView: View {
    @EnvironmentObject var global: Global

    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            joinToHaveAccount
    }
    
    var body: some View {
        List {
            if global.myId == "" {
                Button(action: {
                    activeAlert = .joinToHaveAccount
                }) {
                    HStack {
                        Image(systemName: "person")
                            .font(.title)
                        Text("Account")
                        Spacer()
                    }
                    .background(Color.black.opacity(0.001)) // Expand button's tappable area to empty spaces.
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                NavigationLink(destination: ProfileSettingsAccountView()) {
                    HStack {
                        Image(systemName: "person")
                            .font(.title)
                        Text("Account")
                    }
                }
            }

            // FAQ with info about 5 max chat rooms, future premium plans, SwiftUI app advertisement, etc?
            
            NavigationLink(destination: ProfileSettingsAboutView()) {
                HStack {
                    Image(systemName: "info.circle")
                        .font(.title)
                    Text("About")
                }
            }
            
            Link(destination: URL(string: "mailto:csbuddiesapp@gmail.com")!) {
                HStack {
                    Image(systemName: "envelope")
                        .font(.title)
                    Text("Contact Us")
                    Spacer()
                }
                .background(Color.black.opacity(0.001)) // Expand button's tappable area to empty spaces.
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                global.linkToReview()
            }) {
                HStack {
                    Image(systemName: "star")
                        .font(.title)
                    Text("Rate csBuddies")
                    Spacer()
                }
                .background(Color.black.opacity(0.001)) // Expand button's tappable area to empty spaces.
            }
            .buttonStyle(PlainButtonStyle())
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Settings", displayMode: .inline)
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .joinToHaveAccount:
                return Alert(title: Text("Join us to customize your account."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Join"), action: {
                    global.activeRootView = .join
                }))
            }
        }
    }
}

struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingsView()
    }
}
