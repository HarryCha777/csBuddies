//
//  BetterTextEditor.swift
//  csBuddies
//
//  Created by Harry Cha on 11/15/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct BetterTextEditor: View {
    @EnvironmentObject var global: Global

    let placeholder: String
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .leading) {
            Text(text) // Set height dynamically.
                .opacity(0)
                .padding(.all, 8)
            // Put placeholder behind slightly transparent TextEditor to prevent users from tapping placeholder
            // since allowsHitTesting doesn't work for an unknown reason.
            if text == "" {
                VStack {
                    Text(placeholder)
                        .foregroundColor(Color.gray)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                    Spacer()
                }
            }
            TextEditor(text: $text)
                .opacity(text == "" ? 0.5 : 1)
        }
    }
}
