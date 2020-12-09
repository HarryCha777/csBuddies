//
//  NavigationLinkEmpty.swift
//  csBuddies
//
//  Created by Harry Cha on 11/25/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct NavigationLinkEmpty<Destination>: View where Destination: View {
    let destination: Destination?
    @Binding var isActive: Bool

    var body: some View {
        NavigationLink(destination: destination, isActive: $isActive) {
            EmptyView()
        }
        .opacity(0.0)
        .disabled(true)
    }
}
