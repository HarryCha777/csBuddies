//
//  AppView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/16/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase

struct AppView: View {
    @EnvironmentObject var global: Global
    
    @State private var checkUserTimer = Timer.publish(every: 60 * 2, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            if !Reachability.isConnectedToNetwork() {
                OfflineView()
            } else {
                switch global.activeRootView {
                case .loading:
                    LoadingView()
                case .join:
                    TypeEmailView()
                case .welcome:
                    WelcomeView()
                case .tabs:
                    ZStack {
                        TabsView()
                            .disabled(global.confirmationText != "")
                        ConfirmationView()
                        // Show ConfirmationView on AppView since it does not work in NavigationLink if it is placed in TabsView.
                    }
                case .maintenance:
                    MaintenanceView()
                case .update:
                    UpdateView()
                case .banned:
                    BannedView()
                }
            }
        }
        .onReceive(checkUserTimer) { _ in
            if global.myId != "" &&
                UIApplication.shared.applicationState == .active {
                let postString =
                    "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                    "password=\(global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
                global.runPhp(script: "checkUser", postString: postString) { json in
                    global.likesReceived = json["likesReceived"] as! Int
                    global.isPremium = json["isPremium"] as! Bool
                    let isBanned = json["isBanned"] as! Bool
                    if isBanned {
                        global.activeRootView = .banned
                    } else {
                        if global.activeRootView == .banned {
                            global.activeRootView = .loading
                        }
                    }

                    let mustSyncWithServer = json["mustSyncWithServer"] as! Bool
                    if mustSyncWithServer {
                        global.activeRootView = .loading
                    }
                }
            }
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
            .environmentObject(globalObject)
    }
}
