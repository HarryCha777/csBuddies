//
//  SettingsView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/28/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var global: Global
    @Environment(\.colorScheme) var colorScheme
    
    @State private var currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    var body: some View {
        NavigationView {
            List {
                if global.username != "" {
                    Section(header: Text("Chat")) {
                        NavigationLink(destination: BlockedListView()) {
                            Text("Blocked List")
                        }
                    }
                }
                
                // FAQ with info about 5 max chat rooms, future premium plans, SwiftUI app advertisement, etc?
                
                Section(header: Text("Contact")) {
                    Button(action: {
                        let url = URL(string: "mailto:csbuddiesapp@gmail.com")
                        UIApplication.shared.open(url!)
                    }) {
                        Text("Contact Us")
                            .foregroundColor(colorScheme == .light ? Color.black : Color.white)
                    }
                }
                
                Section(header: Text("Website")) {
                    NavigationLink(destination:
                        WebView(request: URLRequest(url: URL(string: "https://csbuddies.com")!))
                            .navigationBarTitle("csBuddies", displayMode: .inline)
                    ) {
                        Text("csBuddies Website")
                    }
                    
                    NavigationLink(destination:
                        WebView(request: URLRequest(url: URL(string: "https://csbuddies.com/privacy-policy")!))
                            .navigationBarTitle("Privacy Policy", displayMode: .inline)
                    ) {
                        Text("Privacy Policy")
                    }
                    
                    NavigationLink(destination:
                        WebView(request: URLRequest(url: URL(string: "https://csbuddies.com/terms-and-conditions")!))
                            .navigationBarTitle("Terms and Conditions", displayMode: .inline)
                    ) {
                        Text("Terms and Conditions")
                    }
                    
                    NavigationLink(destination:
                        WebView(request: URLRequest(url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!))
                            .navigationBarTitle("Apple's Licence Agreement", displayMode: .inline)
                    ) {
                        Text("Apple's Licence Agreement")
                    }
                }
                
                Section(header: Text("App")) {
                    Button(action: {
                        self.global.linkToReview()
                    }) {
                        Text("Rate the App")
                            .foregroundColor(colorScheme == .light ? Color.black : Color.white)
                    }
                    
                    Text("App Version: \(currentVersion!)")
                }
            }
            .roundCorners()
            .navigationBarTitle("Settings")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
