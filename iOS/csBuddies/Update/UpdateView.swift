//
//  UpdateView.swift
//  csBuddies
//
//  Created by Harry Cha on 6/19/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct UpdateView: View {
    @EnvironmentObject var global: Global
    
    var body: some View {
        SimpleView(
            lottieView: LottieView(name: "attention", size: 300, mustLoop: true),
            title: "Update Required",
            subtitle: global.updateText == "" ? "csBuddies requires an update before continuing." : global.updateText.replacingOccurrences(of: "\\n", with: "\n"),
            bottomView: AnyView(Link(destination: URL(string: "https://apps.apple.com/app/id1524982759")!) {
                ColoredButton(title: "Update")
            }))
    }
}

struct UpdateView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateView()
    }
}
