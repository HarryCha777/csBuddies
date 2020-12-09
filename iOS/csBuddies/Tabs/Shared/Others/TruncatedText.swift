// Source: https://stackoverflow.com/a/59662216

import SwiftUI

struct TruncatedText: View {
    let text: String
    let numberOfLines = 8
    
    // Use @Binding instead of @State to prevent them from resetting on each appearance.
    @Binding var hasExpanded: Bool
    @Binding var hasTruncated: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text(self.text)
                // Remove .font or bottom chunk of text without any new line might not be expanded properly.
                .lineLimit(self.hasExpanded ? nil : numberOfLines)
                // see https://swiftui-lab.com/geometryreader-to-the-rescue/,
                // and https://swiftui-lab.com/communicating-with-the-view-tree-part-1/
                .background(GeometryReader { geometry in
                    Color.clear.onAppear {
                        self.determineTruncation(geometry)
                    }
                })

            if self.hasTruncated {
                Text(self.hasExpanded ? "Read less" : "Read more")
                    .foregroundColor(Color.blue)
                    .onTapGesture {
                        self.hasExpanded.toggle()
                    }
            }
        }
    }
    
    func determineTruncation(_ geometry: GeometryProxy) {
        // Calculate the bounding box we'd need to render the
        // text given the width from the GeometryReader.
        let total = self.text.boundingRect(
            with: CGSize(
                width: geometry.size.width,
                height: .greatestFiniteMagnitude
            ),
            options: .usesLineFragmentOrigin,
            attributes: [.font: UIFont.systemFont(ofSize: 16)],
            context: nil
        )

        if total.size.height > geometry.size.height {
            self.hasTruncated = true
        }
    }
}
