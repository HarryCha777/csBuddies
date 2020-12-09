//
//  NavigationLinkBorderless.swift
//  csBuddies
//
//  Created by Harry Cha on 10/17/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct NavigationLinkBorderless<Content, Destination>: View where Destination: View, Content: View {
    let destination: Destination?
    let content: () -> Content

    @State private var mustVisitDestination = false

    init(destination: Destination, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.destination = destination
    }
    
    var body: some View {
        HStack {
            Button(action: {
                mustVisitDestination = true
            }) {
                content()
            }
            .buttonStyle(PlainButtonStyle()) // Prevent content from being blue.
            .buttonStyle(BorderlessButtonStyle()) // Prevent button from being triggered when anywhere on view is clicked.
            
            NavigationLink(destination: destination, isActive: $mustVisitDestination) {
                EmptyView()
            }
            .opacity(0.0)
            .frame(width: 0, height: 0) // Prevent NavigationLink from taking up space in view.
            .disabled(!mustVisitDestination) // Prevent NavigationLink from being triggered when anywhere on view is clicked.
        }
    }
}
