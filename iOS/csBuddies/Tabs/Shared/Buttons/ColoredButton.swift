//
//  ColoredButton.swift
//  csBuddies
//
//  Created by Harry Cha on 2/5/21.
//  Copyright © 2021 Harry Cha. All rights reserved.
//

import SwiftUI

struct ColoredButton: View {
    let title: String
    let backgroundColor: Color
    let reversed: Bool
    
    init(title: String, backgroundColor: Color = .blue, reversed: Bool = false) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.reversed = reversed
    }
    
    var body: some View {
        Text(title)
            .bold()
            .frame(width: 250)
            .padding()
            .foregroundColor(!reversed ? .white : .blue)
            .background(!reversed ? backgroundColor : Color.clear)
            .cornerRadius(20)
    }
}
