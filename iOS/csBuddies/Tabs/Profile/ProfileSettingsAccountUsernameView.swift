//
//  ProfileSettingsAccountUsernameView.swift
//  csBuddies
//
//  Created by Harry Cha on 11/30/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct ProfileSettingsAccountUsernameView: View {
    @EnvironmentObject var global: Global
    @Environment(\.presentationMode) var presentation
    
    @State private var newUsername = ""
    @State private var reason = ""
    @State private var comments = ""
    @State private var isRequesting = false

    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            sameUsername,
            tooShortUsername,
            invalidCharacterInUsername,
            improperSpacingInUsername,
            tooLongUsername,
            tooLongReason,
            tooLongComments,
            extantUsername,
            extantUsernameChangeRequest
    }
    
    var body: some View {
        ZStack {
            List {
                Text("Your request will be denied if you change your username too frequently.")

                Section(header: Text("New Username")) {
                    TextField("Your new username", text: $newUsername)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            
                Section(header: Text("Reasons")) {
                    TextField("Your reason here.", text: $reason)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            
                Section(header: Text("Comments")) {
                    BetterTextEditor(placeholder: "Please let us know of any additional information to help process this faster.", text: $comments)
                }
            
                Button(action: {
                    isRequesting = true
            
                    if global.username == newUsername {
                        activeAlert = .sameUsername
                    } else if newUsername.count < 6 {
                        activeAlert = .tooShortUsername
                    } else if global.hasInvalidCharacterInUsername(username: newUsername) {
                        activeAlert = .invalidCharacterInUsername
                    } else if global.hasImproperSpacingInUsername(username: newUsername) {
                        activeAlert = .improperSpacingInUsername
                    } else if newUsername.count > 20 {
                        activeAlert = .tooLongUsername
                    } else if reason.count > 100 {
                        activeAlert = .tooLongReason
                    } else if comments.count > 1000 {
                        activeAlert = .tooLongComments
                    } else {
                        checkUsername()
                    }
                }) {
                    Text("Request Username Change")
                        .accentColor(Color.red)
                }
                .disabled(reason == "")
            }
            .listStyle(InsetGroupedListStyle())
            .disabled(isRequesting)
            .opacity(isRequesting ? 0.3 : 1)
            
            if isRequesting {
                LottieView(name: "load", size: 300, mustLoop: true)
            }
        }
        .navigationBarTitle("Request Username Change", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                global.backButton(presentation: presentation, title: "Cancel")
            }
        }
        .alert(item: $activeAlert) { alert in
            DispatchQueue.main.async {
                isRequesting = false
            }

            switch alert {
            case .sameUsername:
                return Alert(title: Text("Same Username"), message: Text("Your new username must be different from your current username."), dismissButton: .default(Text("OK")))
            case .tooShortUsername:
                return Alert(title: Text("Too Short Username"), message: Text("Your username must be at least 6 characters."), dismissButton: .default(Text("OK")))
            case .invalidCharacterInUsername:
                return Alert(title: Text("Invalid Character in Username"), message: Text("Your username must contain only letters, numbers, and spaces."), dismissButton: .default(Text("OK")))
            case .improperSpacingInUsername:
                return Alert(title: Text("Improper Spacing in Username"), message: Text("Your username must not have consecutive spaces or spaces in beginning or end."), dismissButton: .default(Text("OK")))
            case .tooLongUsername:
                return Alert(title: Text("Too Long Username"), message: Text("Your username must be no longer than 20 characters."), dismissButton: .default(Text("OK")))
            case .tooLongReason:
                return Alert(title: Text("Too Long Other Reason"), message: Text("Your other reason must be no longer than 100 characters."), dismissButton: .default(Text("OK")))
            case .tooLongComments:
                return Alert(title: Text("Too Long Comments"), message: Text("Your comments must be no longer than 1,000 characters."), dismissButton: .default(Text("OK")))
            case .extantUsername:
                return Alert(title: Text("Username Already Exists"), message: Text("This username already exists. Please try another username."), dismissButton: .default(Text("OK")))
            case .extantUsernameChangeRequest:
                return Alert(title: Text("Already Requested"), message: Text("You already have a pending username change request. Would you like to replace the previous request with this one?"), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("OK"), action: {
                    isRequesting = true
                    requestUsernameChange()
                }))
            }
        }
    }

    func checkUsername() {
        let postString =
            "myId=&" +
            "username=\(newUsername.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
        global.runPhp(script: "isExtantUsername", postString: postString) { json in
            let isExtantUsername = json["isExtantUsername"] as! Bool
            if isExtantUsername {
                activeAlert = .extantUsername
            } else {
                checkUsernameChangeRequest()
            }
        }
    }
    
    func checkUsernameChangeRequest() {
        let postString =
            "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "password=\(global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
        global.runPhp(script: "isExtantUsernameChangeRequest", postString: postString) { json in
            let isExtantUsernameChangeRequest = json["isExtantUsernameChangeRequest"] as! Bool
            if isExtantUsernameChangeRequest {
                activeAlert = .extantUsernameChangeRequest
            } else {
                requestUsernameChange()
            }
        }
    }
    
    func requestUsernameChange() {
        let postString =
            "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "password=\(global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "newUsername=\(newUsername.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "reason=\(reason.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "comments=\(comments.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
        global.runPhp(script: "requestUsernameChange", postString: postString) { json in
            presentation.wrappedValue.dismiss()
            global.confirmationText = "Requested"
        }
    }
}
