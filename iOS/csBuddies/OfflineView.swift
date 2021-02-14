//
//  OfflineView.swift
//  csBuddies
//
//  Created by Harry Cha on 12/3/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct OfflineView: View {
    @EnvironmentObject var global: Global
    
    var body: some View {
        SimpleView(
            lottieView: LottieView(name: "offline", size: 300, mustLoop: true),
            title: "You are Offline",
            subtitle: "Please try again after connecting to the Internet.",
            bottomView: AnyView(Button(action: {
                    global.isOffline = !Reachability.isConnectedToNetwork()
                }) {
                    ColoredButton(title: "Retry")
                }))
    }
}
