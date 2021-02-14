//
//  RequestNewUsernameView.swift
//  csBuddies
//
//  Created by Harry Cha on 11/30/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct RequestNewUsernameView: View {
    @EnvironmentObject var global: Global
    @Environment(\.presentationMode) var presentation
    
    @State private var newUsername = ""
    @State private var isSelectedList = [Bool](repeating: false, count: 3) // 3 is reasonOptions.count.
    @State private var reasonOptions = ["Typo", "Name Changed", "Other"]
    @State private var reasonIndex = -1
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
            tooLongComments,
            extantUsername,
            extantRequest
    }
    
    var body: some View {
        List {
            Text("Your request will be denied if you change your username too frequently.")
            
            Section(header: Text("New Username")) {
                TextField("Your new username", text: $newUsername)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            Section(header: Text("Reasons")) {
                ForEach(reasonOptions.indices) { index in
                    RadioButton(index: index, reasonIndex: $reasonIndex, reasonOptions: reasonOptions, isSelectedList: $isSelectedList)
                }
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
                } else if comments.count > 1000 {
                    activeAlert = .tooLongComments
                } else {
                    requestNewUsername(mustReplacePrevious: false)
                }
            }) {
                Text("Request Username Change")
                    .accentColor(.red)
            }
            .disabled(newUsername == "" || reasonIndex == -1)
        }
        .listStyle(InsetGroupedListStyle())
        .disabledOnLoad(isLoading: isRequesting)
        .navigationBarTitle("Request Username Change", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                BackButton(title: "Cancel", presentation: presentation)
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
            case .tooLongComments:
                return Alert(title: Text("Too Long Comments"), message: Text("Your comments must be no longer than 1,000 characters."), dismissButton: .default(Text("OK")))
            case .extantUsername:
                return Alert(title: Text("Username Already Exists"), message: Text("This username already exists. Please try another username."), dismissButton: .default(Text("OK")))
            case .extantRequest:
                return Alert(title: Text("Already Requested"), message: Text("You already have a pending username change request. Would you like to replace the previous request with this one?"), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("OK"), action: {
                    isRequesting = true
                    requestNewUsername(mustReplacePrevious: true)
                }))
            }
        }
    }
    
    func requestNewUsername(mustReplacePrevious: Bool) {
        global.firebaseUser!.getIDToken(completion: { (token, error) in
            let postString =
                "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "newUsername=\(newUsername.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "reason=\(reasonIndex)&" +
                "comments=\(comments.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "mustReplacePrevious=\(mustReplacePrevious)"
            global.runPhp(script: "requestNewUsername", postString: postString) { json in
                if json["isExtantUsername"] != nil &&
                    json["isExtantUsername"] as! Bool {
                    activeAlert = .extantUsername
                    return
                }
                
                if json["isExtantRequest"] != nil &&
                    json["isExtantRequest"] as! Bool {
                    activeAlert = .extantRequest
                    return
                }
                
                presentation.wrappedValue.dismiss()
                global.confirmationText = "Requested"
            }
        })
    }
}
