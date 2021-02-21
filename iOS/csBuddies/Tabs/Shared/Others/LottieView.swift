// Source: https://www.rootstrap.com/blog/how-to-use-lottie-animations-in-swiftui/

import SwiftUI
import Lottie

struct LottieUiView: UIViewRepresentable {
    typealias UIViewType = UIView
    
    let name: String
    let speed: CGFloat
    let mustLoop: Bool

    func makeUIView(context: UIViewRepresentableContext<LottieUiView>) -> UIView {
        let view = UIView(frame: .zero)
        
        let animationView = AnimationView()
        let animation = Animation.named(name)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundBehavior = .pauseAndRestore // Pause animation on background and resume on foreground.
        animationView.play()
        
        animationView.animationSpeed = speed
        if mustLoop {
            animationView.loopMode = .loop
        }
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieUiView>) { }
}

struct LottieView: View {
    let name: String
    let size: CGFloat
    let padding: CGFloat?
    let speed: CGFloat?
    let mustLoop: Bool?

    init(name: String, size: CGFloat, padding: CGFloat? = 0, speed: CGFloat? = 1, mustLoop: Bool? = false) {
        self.name = name
        self.size = size
        self.padding = padding
        self.speed = speed
        self.mustLoop = mustLoop
    }

    var body: some View {
        HStack {
            Spacer()
            LottieUiView(name: name, speed: speed!, mustLoop: mustLoop!)
                .frame(width: size, height: size)
                .padding(padding!)
            Spacer()
        }
    }
}
