//
//  FloatingActionButton.swift
//  csBuddies
//
//  Created by Harry Cha on 2/5/21.
//  Copyright © 2021 Harry Cha. All rights reserved.
//

import SwiftUI

struct FloatingActionButton: View {
    let systemName: String
    let action: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    action()
                }) {
                    Image(systemName: systemName)
                        .font(.largeTitle)
                        .frame(width: 75, height: 75)
                        .foregroundColor(.white)
                }
                .background(Color.blue)
                .cornerRadius(40)
                .padding()
                .shadow(color: Color.black.opacity(0.3), radius: 3, x: 3, y: 3)
            }
        }
    }
}
