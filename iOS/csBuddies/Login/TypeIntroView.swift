//
//  TypeIntroView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/17/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase

struct TypeIntroView: View {
    @EnvironmentObject var global: Global
    @Environment(\.colorScheme) var colorScheme
    
    private let introExample =
        "Example:\n" +
            "Hello everyone! My name's Bob.\n" +
            "I'm a college student studying Computer Science in US.\n\n" +
            "My favorite programming language is C#, which I use in Unity3D to build games.\n" +
            "I also like web dev, and you can check it out on my GitHub.\n" +
            "So I'm looking for friends with coding experience, preferably in game or web dev.\n" +
            "Thanks for reading!"
    private struct AlertId: Identifiable {
        enum Id {
            case
            didNotAgree,
            tooShortUsername,
            invalidCharacterInUsername,
            improperSpacingInUsername,
            tooLongUsername,
            tooShortIntro,
            tooLongIntro,
            extantUsername
        }
        var id: Id
    }
    
    @State private var agreed = false
    @State private var isSigningUp = false
    @State private var alertId: AlertId?
    
    var body: some View {
        NavigationView {
            Form {
                Text("Final step!\n" +
                    "Please introduce yourself to others.")
                
                Section(header: Text("Username")) {
                    Text("Your username must be unique and cannot be changed later.")
                    
                    HStack {
                        Text("Username: ")
                        TextField("You may use spaces.", text: $global.username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                Section(header: Text("Self-Introduction")) {
                    MultilineTextField(minHeight: 300, introExample, text: Binding<String>(get: { self.global.intro }, set: {
                        self.global.intro = $0 } ))
                }
                
                Section(header: Text("Agreement")) {
                    Button(action: {
                        self.agreed = !self.agreed
                    }) {
                        HStack {
                            Text("I agree to Apple's License Agreement and Terms and Conditions.")
                                .foregroundColor(colorScheme == .light ? Color.black : Color.white)
                            Spacer()
                            if self.agreed {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 20, height: 20)
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 8, height: 8)
                                }
                            } else {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 20, height: 20)
                                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            }
                        }
                    }

                    NavigationLink(destination:
                        WebView(request: URLRequest(url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!))
                            .navigationBarTitle("Apple's Licence Agreement", displayMode: .inline)
                    ) {
                        Text("View Apple's Licence Agreement.")
                    }

                    NavigationLink(destination:
                        WebView(request: URLRequest(url: URL(string: "https://csbuddies.com/terms-and-conditions")!))
                            .navigationBarTitle("Terms and Conditions", displayMode: .inline)
                    ) {
                        Text("View Terms and Conditions")
                    }
                }

                Button(action: {
                    self.isSigningUp = true
                    
                    if !self.agreed {
                        self.alertId = AlertId(id: .didNotAgree)
                    } else if self.global.username.count < 6 {
                        self.alertId = AlertId(id: .tooShortUsername)
                    } else if self.hasInvalidCharacterInUsername() {
                        self.alertId = AlertId(id: .invalidCharacterInUsername)
                    } else if self.hasImproperSpacingInUsername() {
                        self.alertId = AlertId(id: .improperSpacingInUsername)
                    } else if self.global.username.count > 30 {
                        self.alertId = AlertId(id: .tooLongUsername)
                    } else if self.global.intro.count < 50 {
                        self.alertId = AlertId(id: .tooShortIntro)
                    } else if self.global.intro.count > 1000 {
                        self.alertId = AlertId(id: .tooLongIntro)
                    } else {
                        self.checkUsername()
                    }
                }) {
                    HStack {
                        Text("Finish!")
                            .alert(item: $alertId) { alert in
                                DispatchQueue.main.async {
                                    self.isSigningUp = false
                                }
                                
                                switch alert.id {
                                case .didNotAgree:
                                    return Alert(title: Text("Did Not Agree"), message: Text("You must agree to Apple's Licence Agreement and Terms and Conditions to continue."), dismissButton: .default(Text("OK")))
                                case .tooShortUsername:
                                    return Alert(title: Text("Too Short Username"), message: Text("Your username must be at least 6 characters."), dismissButton: .default(Text("OK")))
                                case .invalidCharacterInUsername:
                                    return Alert(title: Text("Invalid Character in Username"), message: Text("Your username must contain only letters (a-z and A-Z), numbers (0-9), spaces ( ), underscores (_), and dashes (-)."), dismissButton: .default(Text("OK")))
                                case .improperSpacingInUsername:
                                    return Alert(title: Text("Improper Spacing in Username"), message: Text("Your username must not have consecutive spaces or spaces in beginning or end."), dismissButton: .default(Text("OK")))
                                case .tooLongUsername:
                                    return Alert(title: Text("Too Long Username"), message: Text("Your username must be no longer than 30 characters."), dismissButton: .default(Text("OK")))
                                case .tooShortIntro:
                                    return Alert(title: Text("Your intro is too short."), message: Text("You currently typed \(self.global.intro.count) characters. Please write at least 50 characters."), dismissButton: .default(Text("OK")))
                                case .tooLongIntro:
                                    return Alert(title: Text("Your intro is too long."), message: Text("You currently typed \(self.global.intro.count) characters. Please type no more than 1,000 characters."), dismissButton: .default(Text("OK")))
                                case .extantUsername:
                                    return Alert(title: Text("Username Already Exists"), message: Text("This username already exists. Please try another username."), dismissButton: .default(Text("OK")))
                                }
                            }
                    }
                }
                .disabled(isSigningUp)
            }
            .navigationBarTitle("Introduction")
            .modifier(AdaptsToKeyboard())
        }
        .navigationViewStyle(StackNavigationViewStyle()) // needed so screen works on iPad
    }
    
    func hasInvalidCharacterInUsername() -> Bool {
        for index in global.username.indices {
            let c = global.username[index]
            if !(c.isASCII && c.isLetter) &&
                !(c.isASCII && c.isNumber) &&
                c != "_" &&
                c != "-" &&
                c != " " {
                return true
            }
        }
        return false
    }
    
    func hasImproperSpacingInUsername() -> Bool {
        if global.username.first == " " ||
            global.username.last == " " ||
            global.username.contains("  ") {
            return true
        }
        return false
    }
    
    func checkUsername() {
        let postString =
            "username=\(global.username.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
        global.runPhp(script: "isNewUsername", postString: postString) { json in
            let isNewUsername = json["isNewUsername"] as! Bool
            if isNewUsername {
                self.signIn()
            } else {
                self.alertId = AlertId(id: .extantUsername)
            }
        }
    }
    
    func signIn() {
        Auth.auth().signInAnonymously { (result, error) in
            let user = Auth.auth().currentUser
            let changeRequest = user!.createProfileChangeRequest()
            changeRequest.displayName = self.global.username
            changeRequest.commitChanges { (error) in
                user!.getIDTokenForcingRefresh(true, completion: { (token, error) in
                    self.addUser()
                })
            }
        }
    }

    func addUser() {
        let user = Auth.auth().currentUser
        global.password = user!.uid
        
        let postString =
            "username=\(global.username.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "password=\(global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "gender=\(global.genderIndex)&" +
            "birthday=\(global.birthday.toString(toFormat: "yyyy-MM-dd", hasTime: false))&" +
            "country=\(global.countryIndex)&" +
            "interests=\(global.interests.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "otherInterests=\(global.otherInterests.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "level=\(global.levelIndex)&" +
            "intro=\(global.intro.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "gitHub=\(global.gitHub.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "linkedIn=\(global.linkedIn.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
        global.runPhp(script: "addUser", postString: postString) { json in
            self.global.lastVisit = self.global.getUtcTime()
            self.global.lastUpdate = self.global.getUtcTime()
            self.global.accountCreation = self.global.getUtcTime()
            self.global.listenToNewMessages()
            
            self.global.showWelcomeAlert = true
            self.global.isNewUser = false
        }
    }
}

struct TypeIntroView_Previews: PreviewProvider {
    static var previews: some View {
        TypeIntroView()
            .environmentObject(Global())
    }
}
