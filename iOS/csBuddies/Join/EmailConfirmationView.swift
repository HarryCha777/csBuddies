//
//  ConfirmEmailView.swift
//  csBuddies
//
//  Created by Harry Cha on 11/9/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase

struct EmailConfirmationView: View {
    @EnvironmentObject var global: Global
    
    @State private var emailLink = ""
    
    @State var activeEmailConfirmationView: EmailConfirmationViews = .sendingEmail
    enum EmailConfirmationViews: Identifiable {
        var id: Int { self.hashValue }
        case
            sendingEmail,
            sendingEmailFailed,
            sendingEmailSucceeded,
            signingUp,
            signingUpFailed,
            signingUpSucceededNewUser
    }

    var body: some View {
        VStack {
            switch activeEmailConfirmationView {
            case .sendingEmail:
                sendingEmail
            case .sendingEmailFailed:
                sendingEmailFailed
            case .sendingEmailSucceeded:
                sendingEmailSucceeded
            case .signingUp:
                signingUp
            case .signingUpFailed:
                signingUpFailed
            case .signingUpSucceededNewUser:
                signingUpSucceededNewUser
            }
        }
        .onOpenURL(perform: { url in
            emailLink = url.absoluteString
            activeEmailConfirmationView = .signingUp
        })
        .navigationBarTitle("Confirmation", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if activeEmailConfirmationView == .signingUpSucceededNewUser {
                    NavigationLink(destination: SetInterestsView()) {
                        Text("Next")
                    }
                }
            }
        }
    }
    
    var sendingEmail: some View {
        SimpleView(
            lottieView: LottieView(name: "sendEmail", size: 400, speed: 2, mustLoop: true),
            subtitle: "Emailing you a magic link...")
            .onAppear {
                sendEmail()
            }
    }
    
    var sendingEmailFailed: some View {
        SimpleView(
            lottieView: LottieView(name: "error", size: 200),
            title: "Oops, we could not email you.",
            subtitle: "Please make sure you are connected to the internet.",
            bottomView: AnyView(Button(action: {
                activeEmailConfirmationView = .sendingEmail
                sendEmail()
            }) {
                ColoredButton(title: "Try Sending Email Again")
            }))
    }
    
    var sendingEmailSucceeded: some View {
        SimpleView(
            lottieView: LottieView(name: "openEmail", size: 400, padding: -100),
            title: "We emailed you the magic link!",
            subtitle: "Please check your email and tap the link we sent to \(global.email). You may need to check your spam folder.",
            bottomView: AnyView(Link(destination: URL(string: "message://")!) {
                ColoredButton(title: "Open Email App")
            }))
    }

    var signingUp: some View {
        SimpleView(
            lottieView: LottieView(name: "load", size: 300, mustLoop: true),
            subtitle: "Signing you up...")
            .onAppear {
                signUp()
            }
    }
    
    var signingUpFailed: some View {
        SimpleView(
            lottieView: LottieView(name: "error", size: 200),
            title: "Oops, we could not sign you up.",
            subtitle: "Please make sure you are connected to the internet and selected the most recent email we sent you.",
            bottomView: AnyView(Button(action: {
                activeEmailConfirmationView = .sendingEmail
                sendEmail()
            }) {
                ColoredButton(title: "Send Email Again")
            }))
    }
    
    var signingUpSucceededNewUser: some View {
        SimpleView(
            lottieView: LottieView(name: "checkMark", size: 300),
            title: "Awesome, you are signed up!",
            subtitle: "Let's create your profile!")
    }
    
    func sendEmail() {
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://csbuddies.page.link/passwordless")
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        
        Auth.auth().sendSignInLink(toEmail: global.email, actionCodeSettings: actionCodeSettings) { error in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Give some time for email to arrive and sendEmail animation to finish.
                if error != nil {
                    activeEmailConfirmationView = .sendingEmailFailed
                } else {
                    activeEmailConfirmationView = .sendingEmailSucceeded
                }
            }
        }
    }
    
    func signUp() {
        if Auth.auth().isSignIn(withEmailLink: emailLink) {
            Auth.auth().signIn(withEmail: global.email, link: emailLink) { result, error in
                emailLink = ""
                
                if error != nil {
                    activeEmailConfirmationView = .signingUpFailed
                } else {
                    global.firebaseUser = Auth.auth().currentUser
                    global.firebaseUser!.getIDTokenResult(completion: { (result, error) in
                        if result!.claims["userId"] as? String == nil { // User verified email but didn't make a profile.
                            activeEmailConfirmationView = .signingUpSucceededNewUser
                            return
                        }
                        
                        global.hasSignedIn = true
                        global.activeRootView = .loading
                    })
                }
            }
        } else {
            emailLink = ""
            activeEmailConfirmationView = .signingUpFailed
        }
    }
}

struct EmailConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        EmailConfirmationView()
            .environmentObject(globalObject)
    }
}
