// Source: https://stackoverflow.com/a/63102244

/*
Avoid truncating content.
- https://www.allthingsthrifty.com/do-you-hate-truncated-posts/
- https://www.danslelakehouse.com/2016/05/do-you-lovehate-truncated-posts-ps-dans.html

But troll users may create a very long content that takes a while to scroll.
It is not possible to limit users to post content that is less than certain line number
because line numbers differ depending on screen sizes, such as iPhones, iPads, and Mac.

If a long content is not truncated, a "Hide" button for each content may be necessary.
But "Hide" button will also hide bottom bar below the content and take an extra space on action sheet.
Therefore, truncate content only if they are way too long and obviously posted by trolls.
*/

import SwiftUI

struct TruncatedText: View {
    let text: String
    let lineLimit = 30

    // Use @Binding instead of @State to persist the changes on each appearance,
    // but that requires 2 new variables on views that use this view.
    @State var hasExpanded = false
    @State var hasTruncated = false

    var body: some View {
        VStack(alignment: .leading) {
            // Render the real text, which might or might not be limited.
            Text(text)
                .lineLimit(hasExpanded ? nil : lineLimit)
                .background(
                    // Render the limited text and measure its size
                    Text(text)
                        .lineLimit(lineLimit)
                        .background(GeometryReader { displayedGeometry in
                            // Create a ZStack with unbounded height to allow the inner Text as much height as it likes, but no extra width.
                            ZStack {
                                // Render the text without restrictions and measure its size.
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
                        .hidden() // Hide the background.
            )

            // "Show less" button can be implemented if hasTruncated && hasExpanded, but there is no need to make this button.
            if hasTruncated && !hasExpanded {
                Text("Show more")
                    .foregroundColor(.blue)
                    .onTapGesture {
                        self.hasExpanded.toggle()
                    }
            }
        }
        .fixedSize(horizontal: false, vertical: true) // Allow a chunk of text without new lines with only one truncated line to be expanded properly.
    }
}
