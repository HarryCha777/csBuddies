//
//  OfflineView.swift
//  csBuddies
//
//  Created by Harry Cha on 12/3/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct OfflineView: View {
    var body: some View {
        SimpleView(
            lottieView: LottieView(name: "offline", size: 300, mustLoop: true),
            title: "You are Offline",
            subtitle: "We will automatically continue when you are connected to the internet.")
    }
}
