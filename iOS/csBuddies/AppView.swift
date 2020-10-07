//
//  AppView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/16/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct AppView: View {
    @EnvironmentObject var global: Global
    
    var body: some View {
        switch global.viewId.id {
        case .maintenance:
            MaintenanceView()
        case .update:
            UpdateView()
        case .banned:
            BannedView()
        case .signUp:
            SignUpView()
        case .loading:
            LoadingView()
        case .tabs:
            TabsView()
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
