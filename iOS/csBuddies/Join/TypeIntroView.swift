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
        "Hello everybody! My name's Bob.\n" +
        "I'm a college student studying Computer Science in the US.\n\n" +
        "My favorite programming language is C#, and I use it to program video games on Unity3D.\n" +
        "You can check out some of my games on my GitHub profile.\n" +
        "Thanks for reading!"
    
    @State private var agreed = false
    @State private var isAddingUser = false
    
    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            prepermission,
            didNotAgree,
            tooShortUsername,
            invalidCharacterInUsername,
            improperSpacingInUsername,
            tooLongUsername,
            noImage,
            blankIntro,
            tooLongIntro,
            extantUsername
    }
    
    @State var activeSheet: Sheets?
    enum Sheets: Identifiable {
        var id: Int { self.hashValue }
        case
            imagePicker
    }
    
    var body: some View {
        List {
            JoinStepperView(step: 3)
            
            Section(header: Text("Username")) {
                TextField("Your username", text: $global.username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            Section(header: Text("Image")) {
                Button(action: {
                    activeSheet = .imagePicker
                }) {
                    HStack {
                        Spacer()
                        if global.smallImage == "" {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 75, height: 75)
                                .clipShape(Circle())
                        } else {
                            Image(uiImage: global.smallImage.toUiImage())
                                .resizable()
                                .frame(width: 75, height: 75)
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Section(header: Text("Self-Introduction")) {
                VStack {
                    BetterTextEditor(placeholder: introExample, text: $global.intro)
                    Spacer()
                    HStack {
                        Spacer()
                        Text("\(global.intro.count)/256")
                            .padding()
                            .foregroundColor(global.intro.count > 256 ? .red : colorScheme == .light ? .black : .white)
                    }
                }
                if !global.hasAskedNotification {
                    Button(action: {
                        activeAlert = .prepermission
                    }) {
                        Text("Turn on Notification")
                    }
                }
            }
            
            Section(header: Text("Agreement")) {
                Button(action: {
                    agreed = !agreed
                }) {
                    HStack {
                        Text("I agree to Apple's License Agreement and Terms and Conditions.")
                        Spacer()
                        if agreed {
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
                    .background(Color.black.opacity(0.001)) // Expand button's tappable area to empty spaces.
                }
                .buttonStyle(PlainButtonStyle())
                
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
        }
        .listStyle(InsetGroupedListStyle())
        .removeHeaderPadding()
        .disabledOnLoad(isLoading: isAddingUser)
        .navigationBarTitle("Introduction", displayMode: .inline)
        .navigationBarBackButtonHidden(isAddingUser)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    isAddingUser = true
                    
                    if global.username.count < 6 {
                        activeAlert = .tooShortUsername
                    } else if global.hasInvalidCharacterInUsername(username: global.username) {
                        activeAlert = .invalidCharacterInUsername
                    } else if global.hasImproperSpacingInUsername(username: global.username) {
                        activeAlert = .improperSpacingInUsername
                    } else if global.username.count > 20 {
                        activeAlert = .tooLongUsername
                    } else if global.smallImage == "" {
                        activeAlert = .noImage
                    } else if global.intro == "" {
                        activeAlert = .blankIntro
                    } else if global.intro.count > 256 {
                        activeAlert = .tooLongIntro
                    } else if !agreed {
                        activeAlert = .didNotAgree
                    } else {
                        addUser()
                    }
                }) {
                    Text("Finish")
                }
                .disabled(isAddingUser)
            }
        }
        .sheet(item: $activeSheet) { sheet in
            // ImagePickerView should not be inside NavigationView.
            switch sheet {
            case .imagePicker:
                ImagePickerView(sourceType: .photoLibrary) { uiImage in
                    global.smallImage = global.toResizedString(uiImage: uiImage, maxSize: 200.0)
                    global.bigImage = global.toResizedString(uiImage: uiImage, maxSize: 1000.0)
                }
                .environmentObject(globalObject)
            }
        }
        .alert(item: $activeAlert) { alert in
            DispatchQueue.main.async {
                isAddingUser = false
            }
            
            switch alert {
            case .prepermission:
                return Alert(title: Text("Get notified when someone texts you!"),
                             message: Text("Would you like to receive a notification when you receive text messages?"),
                             primaryButton: .destructive(Text("Not Now")),
                             secondaryButton: .default(Text("Notify Me"), action: {
                                global.askNotification()
                             }))
            case .tooShortUsername:
                return Alert(title: Text("Too Short Username"), message: Text("Your username must be at least 6 characters."), dismissButton: .default(Text("OK")))
            case .invalidCharacterInUsername:
                return Alert(title: Text("Invalid Character in Username"), message: Text("Your username must contain only letters, numbers, and spaces."), dismissButton: .default(Text("OK")))
            case .improperSpacingInUsername:
                return Alert(title: Text("Improper Spacing in Username"), message: Text("Your username must not have consecutive spaces or spaces in beginning or end."), dismissButton: .default(Text("OK")))
            case .tooLongUsername:
                return Alert(title: Text("Too Long Username"), message: Text("Your username must be no longer than 20 characters."), dismissButton: .default(Text("OK")))
            case .noImage:
                return Alert(title: Text("You didn't choose an image."), message: Text("Please upload a profile image."), dismissButton: .default(Text("OK")))
            case .blankIntro:
                return Alert(title: Text("Your intro is blank."), message: Text("Your intro cannot be blank."), dismissButton: .default(Text("OK")))
            case .tooLongIntro:
                return Alert(title: Text("Your intro is too long."), message: Text("You currently typed \(global.intro.count) characters. Please type no more than 256 characters."), dismissButton: .default(Text("OK")))
            case .didNotAgree:
                return Alert(title: Text("Did Not Agree"), message: Text("You must agree to Apple's Licence Agreement and Terms and Conditions to continue."), dismissButton: .default(Text("OK")))
            case .extantUsername:
                return Alert(title: Text("Username Already Exists"), message: Text("This username already exists. Please try another username."), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func addUser() {
        global.firebaseUser!.getIDToken(completion: { (token, error) in
            let postString =
                "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "username=\(global.username.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "smallImage=\(global.smallImage.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "bigImage=\(global.bigImage.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "gender=\(global.gender)&" +
                "birthday=\(global.birthday.toString(toFormat: "yyyy-MM-dd"))&" +
                "country=\(global.country)&" +
                "interests=\(global.interests.toInterestsString().addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "otherInterests=\(global.otherInterests.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "intro=\(global.intro.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "github=\(global.github.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "linkedin=\(global.linkedin.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "fcmToken=\(Messaging.messaging().fcmToken!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
            global.runHttp(script: "addUser", postString: postString) { json in
                if json["isExtantUsername"] != nil &&
                    json["isExtantUsername"] as! Bool {
                    activeAlert = .extantUsername
                    return
                }
                
                global.myId = json["myId"] as! String
                
                // Force refresh because backend changed the custom claims.
                global.firebaseUser!.getIDTokenResult(forcingRefresh: true, completion: { (result, error) in
                    global.activeRootView = .loading
                })
            }
        })
    }
}

struct TypeIntroView_Previews: PreviewProvider {
    static var previews: some View {
        TypeIntroView()
            .environmentObject(globalObject)
    }
}
