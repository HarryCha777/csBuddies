// Source: https://github.com/QuynhNguyen/SlidingTabView
// Remove selectionState since it resets selection whenever view leaves screen.

import SwiftUI

public struct SlidingTabView : View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var selection: Int
    let tabs: [String]
    
    let font = Font.body
    let animation = Animation.spring()
    let activeAccentColor = Color.blue
    let inactiveAccentColor = Color.black.opacity(0.4)
    let selectionBarColor = Color.blue
    let inactiveTabColor = Color.clear
    let activeTabColor = Color.clear
    let selectionBarHeight = CGFloat(2)
    let selectionBarBackgroundColor = Color.gray.opacity(0.2)
    let selectionBarBackgroundHeight = CGFloat(1)

    public var body: some View {
        assert(tabs.count > 1, "Must have at least 2 tabs")
        
        return VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                ForEach(tabs, id:\.self) { tab in
                    Button(action: {
                        let selection = tabs.firstIndex(of: tab) ?? 0
                        self.selection = selection
                    }) {
                        HStack {
                            Spacer()
                            Text(tab).font(font)
                            Spacer()
                        }
                    }
                    .buttonStyle(BorderlessButtonStyle()) // Prevent button from being triggered when anywhere on view is clicked.
                    .padding(.vertical, 16)
                    .accentColor(
                        isSelected(tabIdentifier: tab)
                            ? activeAccentColor
                            : colorScheme == .light ? inactiveAccentColor : Color.white)
                    .background(
                        isSelected(tabIdentifier: tab)
                            ? activeTabColor
                            : inactiveTabColor)
                }
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(selectionBarColor)
                        .frame(width: tabWidth(from: geometry.size.width), height: selectionBarHeight, alignment: .leading)
                        .offset(x: selectionBarXOffset(from: geometry.size.width), y: 0)
                        .animation(animation)
                    Rectangle()
                        .fill(selectionBarBackgroundColor)
                        .frame(width: geometry.size.width, height: selectionBarBackgroundHeight, alignment: .leading)
                }.fixedSize(horizontal: false, vertical: true)
            }.fixedSize(horizontal: false, vertical: true)
            
        }
    }
    
    private func isSelected(tabIdentifier: String) -> Bool {
        return tabs[selection] == tabIdentifier
    }
    
    private func selectionBarXOffset(from totalWidth: CGFloat) -> CGFloat {
        return tabWidth(from: totalWidth) * CGFloat(selection)
    }
    
    private func tabWidth(from totalWidth: CGFloat) -> CGFloat {
        return totalWidth / CGFloat(tabs.count)
    }
}
