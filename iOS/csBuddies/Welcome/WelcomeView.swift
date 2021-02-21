// Source: https://github.com/Shubham0812/SwiftUI-Animations/tree/master/SwiftUI-Animations/Code/Animations/LoginView

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var global: Global
    
    let animationDuration: TimeInterval = 0.75
    let offsetDifference: CGFloat = 100
    let gradient: LinearGradient = LinearGradient(gradient: Gradient(colors: [.blue, .red]), startPoint: .leading, endPoint: .trailing)
    
    @State var hasBeganAnimating: Bool = false
    @State var bounceAnimation: Bool = false
    @State var showProfileImage: Bool = false
    @State var switchCircles: Bool = false
    
    @State var circleTrackerDegree: Angle = Angle.degrees(0)
    @State var circleTrackStart: CGFloat = 0
    @State var circleTrackEnd: CGFloat = 0
    @State var blurRadius: CGFloat = 0

    var body: some View {
        ZStack {
            ZStack {
                RoundedTriangle()
                    .fill(Color.blue)
                    .cornerRadius(24)
                    .frame(width: 300, height: self.bounceAnimation ? 100 : 0, alignment: .center)
                    .offset(y: 70)
                    .animation(Animation.spring(response: 0.35, dampingFraction: 0.75, blendDuration: 1)
                                .delay(0.05))
                Circle()
                    .fill(Color.blue)
                    .frame(width: 20)
                    .scaleEffect(self.hasBeganAnimating ? 1 : 0.75)
                    .offset(y:  self.hasBeganAnimating ? -UIScreen.main.bounds.height * 0.31 - offsetDifference : 20)
                    .opacity(self.switchCircles ? 0 : 1)
                    .animation(Animation.easeOut(duration: 0.3).delay(0.2))
            }
            .offset(y: UIScreen.main.bounds.height / 2 - UIScreen.main.bounds.height * 0.09)
            
            ZStack {
                SmallImageView(userId: global.myId, isOnline: false, size: 160)
                    .scaledToFit()
                    .scaleEffect(self.showProfileImage ? 1 : 0)
                    .animation(Animation.spring())
                    .blur(radius: self.showProfileImage ? 0 : 3)
                    .animation(Animation.spring().delay(animationDuration / 1.5))
                    .mask(Circle()
                            .frame(width: 160, height: 160)
                            .shadow(color: .white, radius: 5)
                    )
                
                Circle()
                    .trim(from: circleTrackStart, to: circleTrackEnd)
                    .rotation(.degrees(90))
                    .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .fill(gradient)
                    .frame(width: 185, height: 185)
                
                Circle()
                    .fill(Color.blue)
                    .frame(width: 20)
                    .offset(y: 90)
                    .rotationEffect(circleTrackerDegree)
                    .opacity(self.switchCircles ? 1 : 0)
                
                Text("Welcome,\n\(global.username)!")
                    .font(.system(size: 30, weight: .semibold, design: .monospaced))
                    .padding(.top, 100)
                    .offset(y: offsetDifference * 1.25)
                    .opacity(self.showProfileImage ? 1 : 0)
                    .animation(Animation.easeOut(duration: animationDuration).delay(animationDuration * 1.75))
            }
            .offset(y: -offsetDifference)
            .blur(radius: self.blurRadius)
            .edgesIgnoringSafeArea(.all)
        }
        .onAppear() {
            self.hasBeganAnimating = true
            
            withAnimation(Animation.spring(response: 0.25, dampingFraction: 0.85, blendDuration: 1).delay(0.15)) {
                self.bounceAnimation.toggle()
            }
            Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { _ in
                withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.85, blendDuration: 1)) {
                    self.bounceAnimation.toggle()
                }
                rotateCircles()
            }
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                self.showProfileImage.toggle()
            }
            
            Timer.scheduledTimer(withTimeInterval: 6.5, repeats: false) { _ in
                withAnimation(Animation.default) {
                    self.blurRadius = 6
                }
            }
        }
    }
    
    func rotateCircles() {
        self.switchCircles.toggle()
        circleLines()
        Timer.scheduledTimer(withTimeInterval: animationDuration * 4, repeats: true) { rotationTimer in
            if self.blurRadius == 6 {
                rotationTimer.invalidate()
                global.activeRootView = .tabs
                return
            }
            self.circleTrackStart = 0
            self.circleTrackEnd = 0
            self.circleTrackerDegree = .degrees(0)
            circleLines()
        }
    }
    
    func circleLines() {
        withAnimation(Animation.easeIn(duration: animationDuration).delay(0.45)) {
            self.circleTrackerDegree = .degrees(360)
        }
        withAnimation(Animation.easeIn(duration: animationDuration).delay(0.5)) {
            self.circleTrackEnd = 1
        }
        Timer.scheduledTimer(withTimeInterval: animationDuration * 2, repeats: false) { _ in
            withAnimation(Animation.easeIn(duration: animationDuration).delay(0.25)) {
                self.circleTrackStart = 1
            }
            self.circleTrackerDegree = .degrees(0)
            withAnimation(Animation.easeIn(duration: animationDuration).delay(0.25)) {
                self.circleTrackerDegree = .degrees(360)
            }
        }
    }
}

struct RoundedTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addCurve(to: CGPoint(x: rect.midX, y: rect.minY), control1: CGPoint(x: rect.midX + 124, y: rect.minY), control2: CGPoint(x: rect.midX, y: rect.minY))
        path.addCurve(to: CGPoint(x: rect.minX, y: rect.maxY), control1: CGPoint(x: rect.midX, y: rect.minY), control2: CGPoint(x: rect.midX - 124, y: rect.minY))

        return path
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .environmentObject(globalObject)
    }
}
