// Source: https://stackoverflow.com/a/57869749

import SwiftUI

struct SGNavigationLink<Content, Destination>: View where Destination: View, Content: View {
    let destination: Destination?
    let content: () -> Content

    @State private var isLinkActive = false

    init(destination: Destination, title: String = "", @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.destination = destination
    }

    var body: some View {
        return ZStack(alignment: .leading) {
            content()
            
            // This if condition allows clicking on messages in chat room, but removes transition animation in iOS 14.
            if isLinkActive {
                NavigationLink(destination: destination, isActive: $isLinkActive) {
                    EmptyView()
                }
                .frame(width: 0, height: 0)
            }
        }
        .onTapGesture {
            self.isLinkActive = true
        }
    }
}
