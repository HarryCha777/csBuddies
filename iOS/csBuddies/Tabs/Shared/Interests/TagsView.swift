// Source: https://github.com/zntfdr/FiveStarsCodeSamples/tree/main/Flexible-SwiftUI

import SwiftUI

struct TagsView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let content: (Data.Element) -> Content
    @State private var availableWidth: CGFloat = 0
    
    let spacing: CGFloat = 8
    @State private var elementsSize: [Data.Element: CGSize] = [:]
    @State private var isLoading = false
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
            if !isLoading {
                Color.clear
                    .frame(height: 0.001)
                    .readSize { size in
                        availableWidth = size.width
                    }
                
                VStack(alignment: .leading, spacing: spacing) {
                    ForEach(computeRows(), id: \.self) { rowElements in
                        HStack(spacing: spacing) {
                            ForEach(rowElements, id: \.self) { element in
                                content(element)
                                    .fixedSize()
                                    .readSize { size in
                                        elementsSize[element] = size
                                    }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            if isLoading {
                return
            }
            isLoading = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) { // Prevent the view from having unnecessary extra height in List by updating the view.
                // Unlike waiting to prevent calling PHP twice on each load, wait for only 0.001 seconds since it is much faster than 0.1 seconds.
                isLoading = false
            }
        }
    }
    
    func computeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        var currentRow = 0
        var remainingWidth = availableWidth
        
        for element in data {
            let elementSize = elementsSize[element, default: CGSize(width: availableWidth, height: 1)]
            
            if remainingWidth - (elementSize.width + spacing) >= 0 {
                rows[currentRow].append(element)
            } else {
                currentRow = currentRow + 1
                rows.append([element])
                remainingWidth = availableWidth
            }
            
            remainingWidth = remainingWidth - (elementSize.width + spacing)
        }
        
        return rows
    }
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
