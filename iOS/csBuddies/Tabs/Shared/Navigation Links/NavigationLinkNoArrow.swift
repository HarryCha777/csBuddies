//
//  NavigationLinkNoArrow.swift
//  csBuddies
//
//  Created by Harry Cha on 10/17/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct NavigationLinkNoArrow<Content, Destination>: View where Destination: View, Content: View {
    let destination: Destination?
    let isDisabled: Bool
    let content: () -> Content

    init(destination: Destination, isDisabled: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.isDisabled = isDisabled
        self.destination = destination
    }

    var body: some View {
        if isDisabled {
            content() // Disable NavigationLink without making it gray like .disabled(true).
        } else {
            HStack {
                content()
                
                NavigationLink(destination: destination) {
                    EmptyView()
                }
                .opacity(0.0)
                .frame(width: 0, height: 0) // Prevent NavigationLink from taking up space in view.
            }
        }
    }
}
