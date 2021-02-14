//
//  DeleteAccountView.swift
//  csBuddies
//
//  Created by Harry Cha on 11/18/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase

struct DeleteAccountView: View {
    @EnvironmentObject var global: Global
    @Environment(\.presentationMode) var presentation
    
    @State private var isReasonsView = false
    
    @State private var isSelectedList = [Bool](repeating: false, count: 7) // 7 is reasonOptions.count.
    @State private var reasonOptions = ["Nobody talked to me.", "The users are mean.", "I saw inappropriate content.", "I got spammed.", "The app is buggy", "I need a break.", "Other"]
    @State private var reasonIndex = -1
    @State private var comments = ""
    @State private var isUpdatingAccount = false
    
    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            tooLongComments
    }
    
    var body: some View {
        VStack {
            if !isReasonsView {
                SimpleView(
                    lottieView: LottieView(name: "error", size: 200),
                    title: "Are you sure?",
                    subtitle: "Your profile will be inaccessible to all users, and you will be unable to create a new account with the same email address (\(global.firebaseUser!.email!)).",
                    bottomView: AnyView(VStack {
                        Link(destination: URL(string: "mailto:csbuddiesapp@gmail.com")!) {
                            ColoredButton(title: "Contact Us", reversed: true)
                        }
                        Button(action: {
                            self.isReasonsView = true
                        }) {
                            ColoredButton(title: "Delete Account", backgroundColor: .red)
                        }
                    }))
                
            } else {
                List {
                    Text("We are sorry to see you go! Please consider letting us know why you left.")
                    
                    Section(header: Text("Reasons")) {
                        ForEach(reasonOptions.indices) { index in
                            RadioButton(index: index, reasonIndex: $reasonIndex, reasonOptions: reasonOptions, isSelectedList: $isSelectedList)
                        }
                    }
                    
                    Section(header: Text("Comments")) {
                        BetterTextEditor(placeholder: "Please let us know of any additional information to help us improve, thank you!", text: $comments)
                    }
                    
                    Button(action: {
                        isUpdatingAccount = true
                        
                        if comments.count > 1000 {
                            activeAlert = .tooLongComments
                        } else {
                            deleteAccount()
                        }
                    }) {
                        Text("Delete Account")
                            .accentColor(.red)
                    }
                    .disabled(reasonIndex == -1)
                }
                .listStyle(InsetGroupedListStyle())
                .disabledOnLoad(isLoading: isUpdatingAccount)
            }
        }
        .navigationBarTitle("Delete Account", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                BackButton(title: "Cancel", presentation: presentation)
            }
        }
        .alert(item: $activeAlert) { alert in
            DispatchQueue.main.async {
                isUpdatingAccount = false
            }
            
            switch alert {
            case .tooLongComments:
                return Alert(title: Text("Too Long Comments"), message: Text("Your comments must be no longer than 1,000 characters."), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func deleteAccount() {
        global.firebaseUser!.getIDToken(completion: { (token, error) in
            let postString =
                "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "reason=\(reasonIndex)&" +
                "comments=\(comments.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
            global.runPhp(script: "deleteUser", postString: postString) { json in
                // Simply sign out instead of unnecessarily deleting Firebase account.
                // In fact, Firebase throws an error on account deletion attempt unless they recently signed in.
                // You can also recover others' accounts on the accounts table unless they manually deleted their accounts by themselves.
                
                global.resetUserData()
                try! Auth.auth().signOut()
                presentation.wrappedValue.dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Needed to make presentation.wrappedValue.dismiss() work.
                    global.activeRootView = .loading
                }
            }
        })
    }
}
