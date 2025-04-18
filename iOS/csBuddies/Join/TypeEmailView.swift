//
//  TypeEmailView.swift
//  csBuddies
//
//  Created by Harry Cha on 11/9/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase

struct TypeEmailView: View {
    @EnvironmentObject var global: Global
    
    @State private var isVerifyingEmail = false
    @State private var mustVisitEmailConfirmation = false
    
    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            tooLongEmail,
            notValidEmail,
            deletedEmail
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    TextField("Your email address", text: $global.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .font(.title)
                    Spacer()
                        .frame(height: 30)
                    Text("You don't need a password. We'll send a magic link to your email!")
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                .padding()
                .disabledOnLoad(isLoading: isVerifyingEmail)
                
                NavigationLinkEmpty(destination: EmailConfirmationView(), isActive: $mustVisitEmailConfirmation)
            }
            .navigationBarTitle("Email")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        global.activeRootView = .tabs
                    }) {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        isVerifyingEmail = true
                        
                        if global.email.count > 320 {
                            activeAlert = .tooLongEmail
                        } else if !isValidEmail() {
                            activeAlert = .notValidEmail
                        } else {
                            checkDeletedEmail()
                        }
                    }) {
                        Text("Next")
                    }
                    .disabled(global.email == "")
                }
            }
            .alert(item: $activeAlert) { alert in
                DispatchQueue.main.async {
                    isVerifyingEmail = false
                }
                
                switch alert {
                case .tooLongEmail:
                    return Alert(title: Text("Too Long Email"), message: Text("Your email must be no longer than 320 characters."), dismissButton: .default(Text("OK")))
                case .notValidEmail:
                    return Alert(title: Text("Invalid Email"), message: Text("Your email is not valid. Please double-check your spelling."), dismissButton: .default(Text("OK")))
                case .deletedEmail:
                    return Alert(title: Text("Deleted Email"), message: Text("This email is already used to create and delete an account. Please use another email."), dismissButton: .default(Text("OK")))
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: global.email)
    }
    
    func checkDeletedEmail() {
        let postString =
            "email=\(global.email.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
        global.runHttp(script: "isDeletedEmail", postString: postString) { json in
            if json["isDeletedEmail"] as! Bool {
                activeAlert = .deletedEmail
                return
            }
            
            isVerifyingEmail = false // Set isVerifyingEmail to false in case user presses back button on the next screen.
            mustVisitEmailConfirmation = true
        }
    }
}
