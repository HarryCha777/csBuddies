// Source: https://stackoverflow.com/a/56496896
// ProgressView cannot resize and is less customizable.

import UIKit
import SwiftUI

struct ActivityIndicatorView: UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicatorView>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: .large)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicatorView>) {
        uiView.startAnimating()
    }
}
