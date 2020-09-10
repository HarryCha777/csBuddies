//
//  MustUpdateView.swift
//  csBuddies
//
//  Created by Harry Cha on 6/19/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct MustUpdateView: View {
    var body: some View {
        VStack {
            Text("Update Required")
                .font(.largeTitle)
                .padding()
            
            Button(action: {
                let url = URL(string: "https://apps.apple.com/app/id1524982759")
                UIApplication.shared.open(url!)
            }) {
                Text("This app requires an update before continuing. Please update the app by clicking ") +
                    Text("here")
                        .foregroundColor(Color.blue) +
                    Text(".")
            }
            .buttonStyle(PlainButtonStyle())
            .padding()
        }
    }
}

struct MustUpdateView_Previews: PreviewProvider {
    static var previews: some View {
        MustUpdateView()
    }
}
