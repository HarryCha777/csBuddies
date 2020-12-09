//
//  ProfileSettingsPrivacyView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/28/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase

struct ProfileSettingsPrivacyView: View {
    @EnvironmentObject var global: Global
    
    let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

    var body: some View {
        Form {
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
            
            Text("App Version: \(currentVersion!)")
        }
        .navigationBarTitle("Privacy", displayMode: .inline)
    }
}
