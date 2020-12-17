//
//  ProfileSettingsAboutAttributionView.swift
//  csBuddies
//
//  Created by Harry Cha on 12/13/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct ProfileSettingsAboutAttributionView: View {
    @EnvironmentObject var global: Global
    
    let attributions = [
        "Load: LottieFiles @LottieFiles",
        "Chat: Goyo @LottieFiles",
        "Team: Jàllouli Yàssine @LottieFiles",
        "Send Email: Joel Chan @LottieFiles",
        "Open Email: Jeffrey Christopher @LottieFiles",
        "Check Mark: Tu Nguyen @LottieFiles",
        "Offline: Luis Pérez @LottieFiles",
        "Error: Kleant Zogu @LottieFiles",
        "Attention: Issey @LottieFiles",
        "No Data: Nazar @LottieFiles",
        "Like: LottieFiles @LottieFiles"
    ]

    var body: some View {
        Form {
            ForEach(attributions, id: \.self) { attribution in
                Text(attribution)
            }
        }
        .navigationBarTitle("Animation Attribution", displayMode: .inline)
    }
}
