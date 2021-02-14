//
//  DisableAccountView.swift
//  csBuddies
//
//  Created by Harry Cha on 2/9/21.
//  Copyright © 2021 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase

struct DisableAccountView: View {
    @EnvironmentObject var global: Global
    @Environment(\.presentationMode) var presentation
    
    @State private var isUpdatingAccount = false
    
    var body: some View {
        SimpleView(
            lottieView: LottieView(name: "error", size: 200),
            title: "Are you sure?",
            subtitle: "Your inbox and chat history will be deleted, and your profile will be hidden from Buddies tab until you sign back in.",
            bottomView: AnyView(VStack {
                Link(destination: URL(string: "mailto:csbuddiesapp@gmail.com")!) {
                    ColoredButton(title: "Contact Us", reversed: true)
                }
                Button(action: {
                    isUpdatingAccount = true
                    
                    global.firebaseUser!.getIDToken(completion: { (token, error) in
                        let postString =
                            "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                            "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
                        global.runPhp(script: "disableUser", postString: postString) { json in
                            global.resetUserData()
                            try! Auth.auth().signOut()
                            presentation.wrappedValue.dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Needed to make presentation.wrappedValue.dismiss() work.
                                global.activeRootView = .loading
                            }
                        }
                    })
                }) {
                    ColoredButton(title: "Disable Account", backgroundColor: .red)
                }
            }))
            .disabledOnLoad(isLoading: isUpdatingAccount)
            .navigationBarTitle("Disable Account", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    BackButton(title: "Cancel", presentation: presentation)
                }
            }
    }
}
