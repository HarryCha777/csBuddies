// Source: https://stackoverflow.com/a/57869749

import SwiftUI

struct SGNavigationLink<Content, Destination>: View where Destination: View, Content: View {
    let destination: Destination?
    let content: () -> Content

    @State private var isLinkActive:Bool = false

    init(destination: Destination, title: String = "", @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.destination = destination
    }

    var body: some View {
        return ZStack (alignment: .leading){
            if self.isLinkActive{
                NavigationLink(destination: destination, isActive: $isLinkActive) {
                    Color.clear
                }
                .frame(width: 0, height: 0)
            }
            content()
        }
        .onTapGesture {
            self.pushHiddenNavLink()
        }
    }

    func pushHiddenNavLink(){
        self.isLinkActive = true
    }
}
