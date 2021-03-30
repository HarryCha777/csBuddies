//
//  RadioButton.swift
//  csBuddies
//
//  Created by Harry Cha on 2/10/21.
//  Copyright © 2021 Harry Cha. All rights reserved.
//

import SwiftUI

struct RadioButton: View {
    @EnvironmentObject var global: Global
    
    let index: Int
    @Binding var reason: Int
    @State var reasonOptions: [String]
    @Binding var isSelectedList: [Bool]
    
    var body: some View {
        Button(action: {
            isSelectedList = [Bool](repeating: false, count: reasonOptions.count)
            isSelectedList[index] = true
            reason = index
        }) {
            HStack {
                Text(reasonOptions[index])
                Spacer()
                if index < isSelectedList.count && isSelectedList[index] {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 20, height: 20)
                        Circle()
                            .fill(Color.white)
                            .frame(width: 8, height: 8)
                    }
                } else {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                }
            }
            .background(Color.black.opacity(0.001)) // Expand button's tappable area to empty spaces.
        }
        .buttonStyle(PlainButtonStyle())
    }
}
