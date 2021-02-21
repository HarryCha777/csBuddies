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
    
    var body: some View {
        VStack {
            if global.isOffline {
                OfflineView()
                    .environmentObject(globalObject)
            } else {
                switch global.activeRootView {
                case .loading:
                    LoadingView()
                        .environmentObject(globalObject)
                case .welcome:
                    WelcomeView()
                        .environmentObject(globalObject)
                case .join:
                    TypeEmailView()
                        .environmentObject(globalObject)
                case .tabs:
                    TabsView()
                        .environmentObject(globalObject)
                case .maintenance:
                    MaintenanceView()
                        .environmentObject(globalObject)
                case .update:
                    UpdateView()
                        .environmentObject(globalObject)

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
