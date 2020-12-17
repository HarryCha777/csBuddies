// Source: https://stackoverflow.com/a/63102244

import SwiftUI

struct TruncatedText: View {
    let text: String
    let lineLimit = 8

    // Use @Binding instead of @State to prevent them from resetting on each appearance.
    @Binding var hasExpanded: Bool
    @Binding var hasTruncated: Bool

    var body: some View {
        VStack(alignment: .leading) {
            // Render the real text (which might or might not be limited)
            Text(text)
                .lineLimit(hasExpanded ? nil : lineLimit)
                .background(
                    // Render the limited text and measure its size
                    Text(text)
                        .lineLimit(lineLimit)
                        .background(GeometryReader { displayedGeometry in
                            // Create a ZStack with unbounded height to allow the inner Text as much
                            // height as it likes, but no extra width.
                            ZStack {
                                // Render the text without restrictions and measure its size
                                Text(self.text)
                                    .background(GeometryReader { fullGeometry in
                                        // And compare the two
                                        Color.clear.onAppear {
                                            self.hasTruncated = fullGeometry.size.height > displayedGeometry.size.height
                                        }
                                    })
                            }
                            .frame(height: .greatestFiniteMagnitude)
                        })
                        .hidden() // Hide the background
            )

            if hasTruncated {
                Text(self.hasExpanded ? "Show less" : "Show more")
                    .foregroundColor(Color.blue)
                    .onTapGesture {
                        self.hasExpanded.toggle()
                    }
            }
        }
        .fixedSize(horizontal: false, vertical: true) // Allow a chunk of text without new lines with only one truncated line to be expanded properly.
    }
}
