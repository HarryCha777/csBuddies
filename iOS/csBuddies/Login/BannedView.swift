//
//  BannedView.swift
//  csBuddies
//
//  Created by Harry Cha on 6/19/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct BannedView: View {
    var body: some View {
        VStack {
            Text("You are banned.")
                .font(.largeTitle)
                .padding()
            
            Text("You have violated one or more agreements in Apple's Licence Agreement or Terms and Conditions.\n" +
                "If you think you have been banned unfairly, please contact us.")
                .padding()
            
            Button(action: {
                let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
                UIApplication.shared.open(url!)
            }) {
                Text("Apple's Licence Agreement")
            }
            .padding()

            Button(action: {
                let url = URL(string: "https://csbuddies.com/terms-and-conditions")
                UIApplication.shared.open(url!)
            }) {
                Text("Terms and Conditions")
            }
            .padding()

            Button(action: {
                let url = URL(string: "mailto:csbuddiesapp@gmail.com")
                UIApplication.shared.open(url!)
            }) {
                Text("Contact Us")
            }
            .padding()
        }
    }
}

struct BannedView_Previews: PreviewProvider {
    static var previews: some View {
        BannedView()
    }
}
