//
//  MaintenanceView.swift
//  csBuddies
//
//  Created by Harry Cha on 10/1/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct MaintenanceView: View {
    @EnvironmentObject var global: Global
    
    var body: some View {
        SimpleView(
            lottieView: LottieView(name: "maintenance", size: 300, mustLoop: true),
            title: "Under Maintenance",
            subtitle: global.maintenanceText == "" ? "csBuddies is currently undergoing maintenance. We will be back shortly. Thank you for your patience." : global.maintenanceText,
            bottomView: AnyView(Button(action: {
                global.runHttp(script: "getConfig", postString: "") { json in
                    global.maintenanceText = json["maintenanceText"] as! String
                    
                    let isUnderMaintenance = json["isUnderMaintenance"] as! Bool
                    if !isUnderMaintenance {
                        global.activeRootView = .loading
                    }
                }
            }) {
                ColoredButton(title: "Reload")
            }))
    }
}
