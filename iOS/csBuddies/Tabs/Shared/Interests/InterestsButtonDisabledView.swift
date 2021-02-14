//
//  InterestsButtonDisabledView.swift
//  csBuddies
//
//  Created by Harry Cha on 11/12/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct InterestsButtonDisabledView: View {
    @EnvironmentObject var global: Global
    @Environment(\.colorScheme) var colorScheme
    
    let interest: String
    let interests: [String]
    let lightBlueColor = Color(red: 30 / 255, green: 144 / 255, blue: 255 / 255)

    var body: some View {
        Text(verbatim: interest)
            .padding(6)
            .foregroundColor(interests.contains(interest) ? .white : lightBlueColor)
            .overlay(RoundedRectangle(cornerRadius: 15)
                        .stroke(lightBlueColor, lineWidth: 1))
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(interests.contains(interest) ? lightBlueColor : colorScheme == .light ? .white : .black)
            )
    }
}
