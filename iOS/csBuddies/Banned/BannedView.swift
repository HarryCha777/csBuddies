//
//  BannedView.swift
//  csBuddies
//
//  Created by Harry Cha on 6/19/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct BannedView: View {
    @EnvironmentObject var global: Global
    
    var body: some View {
        SimpleView(
            lottieView: LottieView(name: "error", size: 200),
            title: "You are banned.",
            subtitle: "You have violated one or more agreements in Apple's Licence Agreement or Terms and Conditions. If you think you have been banned unfairly, please contact us.",
            bottomView: AnyView(VStack(spacing: 0) {
                Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                    global.blueButton(title: "Apple's Licence Agreement", reversed: true)
                }
                Link(destination: URL(string: "https://csbuddies.com/terms-and-conditions")!) {
                    global.blueButton(title: "Terms and Conditions", reversed: true)
                }
                Link(destination: URL(string: "mailto:csbuddiesapp@gmail.com")!) {
                    global.blueButton(title: "Contact Us")
                }
            }))
    }
}

struct BannedView_Previews: PreviewProvider {
    static var previews: some View {
        BannedView()
    }
}
