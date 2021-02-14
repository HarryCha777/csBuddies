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
            } else {
                switch global.activeRootView {
                case .loading:
                    LoadingView()
                case .welcome:
                    WelcomeView()
                case .join:
                    TypeEmailView()
                case .tabs:
                    TabsView()
                case .maintenance:
                    MaintenanceView()
                case .update:
                    UpdateView()
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
