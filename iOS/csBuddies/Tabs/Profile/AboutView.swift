//
//  AboutView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/28/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct AboutView: View {
    @EnvironmentObject var global: Global
    
    let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

    var body: some View {
        Form {
            Section(header: Text("Agreements")) {
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
            
            Section(header: Text("Credits")) {
                NavigationLink(destination: AttributionView()) {
                    Text("Animation Attribution")
                }
            }

            Section(header: Text("csBuddies")) {
                NavigationLink(destination:
                                WebView(request: URLRequest(url: URL(string: "https://csbuddies.com")!))
                                .navigationBarTitle("csBuddies", displayMode: .inline)
                ) {
                    Text("csBuddies Website")
                }
                
                Text("App Version: \(currentVersion!)")
            }
        }
        .navigationBarTitle("Privacy", displayMode: .inline)
    }
}
