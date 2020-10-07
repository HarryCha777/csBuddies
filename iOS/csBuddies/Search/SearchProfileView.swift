//
//  SearchProfileView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/22/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase

struct SearchProfileView: View {
    @EnvironmentObject var global: Global
    @Environment(\.colorScheme) var colorScheme
    
    private struct AlertId: Identifiable {
        enum Id {
            case
            mustSignUpToMessage,
            mustSignUpToBlock,
            mustSignUpToReport
        }
        var id: Id
    }
    
    let buddyUsername: String
    
    @State private var buddyImage = ""
    @State private var buddyGenderIndex = 0
    @State private var buddyBirthday = Date()
    @State private var buddyCountryIndex = 0
    @State private var buddyInterests = ""
    @State private var buddyLevelIndex = 0
    @State private var buddyIntro = ""
    @State private var buddyGitHub = ""
    @State private var buddyLinkedIn = ""
    @State private var buddyLastVisit = Date()
    @State private var buddyLastUpdate = Date()
    @State private var buddyAccountCreation = Date()
    @State private var isReady = false
    @State private var alertId: AlertId?

    var body: some View {
        List {
            if isReady {
                HStack {
                    VStack {
                        Spacer()
                        if buddyImage == "" {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 75, height: 75)
                                .clipShape(Circle())
                        } else {
                            Image(uiImage: buddyImage.toUiImage())
                                .resizable()
                                .frame(width: 75, height: 75)
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    
                    Spacer()
                        .frame(width: 15)
                    
                    VStack(alignment: .leading) {
                        Text("\(buddyUsername)")
                            .bold()
                            .font(.title)
                        HStack {
                            if buddyGenderIndex == 0 {
                                Text("\(global.genderOptions[buddyGenderIndex])")
                                    .foregroundColor(Color.blue) +
                                    Text(",")
                            } else if buddyGenderIndex == 1 {
                                Text("\(global.genderOptions[buddyGenderIndex])")
                                    .foregroundColor(Color(red: 255 / 255, green: 20 / 255, blue: 147 / 255)) + // pink
                                    Text(",")
                            } else if buddyGenderIndex == 2 ||
                                        buddyGenderIndex == 3 {
                                Text("\(global.genderOptions[buddyGenderIndex])")
                                    .foregroundColor(Color.gray) +
                                    Text(",")
                            } else {
                                Text("Unknown") +
                                    Text(",")
                            }
                            Text("\(buddyBirthday.toString(toFormat: "yyyy")[0] != "0" ? "\(buddyBirthday.toAge())" : "N/A")")
                        }
                        Text("\(global.countryOptions[safe: buddyCountryIndex] ?? "Unknown")")
                    }
                }
                
                Section(header: Text("Self-Introduction")) {
                    if buddyIntro.count == 0 {
                        Text("Did not write a self-introduction.")
                    } else {
                        Text("\(buddyIntro)")
                    }
                    if self.buddyGitHub.count != 0 {
                        NavigationLink(destination:
                            WebView(request: URLRequest(url: URL(string: "https://www.github.com/\(self.buddyGitHub)")!))
                                .navigationBarTitle("GitHub", displayMode: .inline)
                        ) {
                            Image("gitHubLogo")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .if(colorScheme == .dark) { content in
                                    content.colorInvert() // invert color on dark mode
                                }
                            Text("https://www.github.com/\(self.buddyGitHub)")
                                .foregroundColor(Color.blue)
                        }
                    }
                    if self.buddyLinkedIn.count != 0 {
                        NavigationLink(destination:
                            WebView(request: URLRequest(url: URL(string: "\(self.buddyLinkedIn)")!))
                                .navigationBarTitle("LinkedIn", displayMode: .inline)
                        ) {
                            Image("linkedInLogo")
                                .resizable()
                                .frame(width: 22, height: 22)
                            Text("\(self.buddyLinkedIn)")
                                .foregroundColor(Color.blue)
                        }
                    }
                }
                
                Section(header: Text("Interests")) {
                    if buddyInterests.count == 0 {
                        Text("Did not select any interest.")
                    } else {
                        Text("\(buddyInterests.toReadableInterests())")
                    }
                    HStack {
                        Text("Level")
                        Spacer()
                        Text("\(global.levelOptions[safe: buddyLevelIndex] ?? "Unknown")")
                    }
                }
                
                // Since the users are not very active yet, last visit may discourage new users from messaging old users.
                // Uncomment the Activity section only when the app is more active so that new users will get encouraged to see other users' last visit.
                // Mark "Today" and "Yesterday" in text.
                /*Section(header: Text("Activity")) {
                    HStack {
                        Text("Last Visit")
                        Spacer()
                        Text("\(buddyLastVisit.toLocal().toString(toFormat: "M/d/yy"))")
                    }
                    HStack {
                        Text("Last Update")
                        Spacer()
                        Text("\(buddyLastUpdate.toLocal().toString(toFormat: "M/d/yy"))")
                    }
                    HStack {
                        Text("Account Created")
                        Spacer()
                        Text("\(buddyAccountCreation.toLocal().toString(toFormat: "M/d/yy"))")
                    }
                }*/
                
                Section(header: Text("Action")) {
                    if global.username == "" {
                        Button(action: {
                            self.alertId = AlertId(id: .mustSignUpToMessage)
                        }) {
                            Text("Message User")
                                .foregroundColor(Color.blue)
                        }

                        Button(action: {
                            self.alertId = AlertId(id: .mustSignUpToBlock)
                        }) {
                            Text("Block User")
                                .foregroundColor(Color.red)
                        }
                        
                        Button(action: {
                            self.alertId = AlertId(id: .mustSignUpToReport)
                        }) {
                            Text("Report User")
                                .foregroundColor(Color.red)
                        }
                    } else {
                        ZStack(alignment: .leading) {
                            Text("Message User")
                                .foregroundColor(Color.blue)
                        
                            // Hide navigation link arrow by making invisible navigation link in ZStack.
                            NavigationLink(destination: ChatRoomView(buddyUsername: buddyUsername)) {
                                EmptyView()
                            }
                            .if(UIDevice.current.systemVersion[0...1] == "13") { content in
                                // This hides arrow in iOS 13, but disables link in iOS 14.
                                content.hidden()
                            }
                        }
                        
                        if !global.blockedList.contains(buddyUsername) {
                            Button(action: {
                                self.global.block(buddyUsername: self.buddyUsername)
                            }) {
                                Text("Block User")
                                    .foregroundColor(Color.red)
                            }
                        } else {
                            Button(action: {
                                self.global.unblock(buddyUsername: self.buddyUsername)
                            }) {
                                Text("Unblock User")
                            }
                        }
                        
                        ZStack(alignment: .leading) {
                            Text("Report User")
                                .foregroundColor(Color.red)
                        
                            // Hide navigation link arrow by making invisible navigation link in ZStack.
                            NavigationLink(destination: SearchProfileReportView(buddyUsername: buddyUsername)) {
                                EmptyView()
                            }
                            .if(UIDevice.current.systemVersion[0...1] == "13") { content in
                                // This hides arrow in iOS 13, but disables link in iOS 14.
                                content.hidden()
                            }
                        }
                    }
                }
            }
        }
        .roundCorners()
        .navigationBarTitle("\(buddyUsername)", displayMode: .inline)
        .if(global.username == "") { content in
            content
                .navigationBarItems(trailing:
                    Button(action: {
                        self.alertId = AlertId(id: .mustSignUpToMessage)
                    }) {
                        Image(systemName: "text.bubble")
                            .imageScale(.large)
                    }
                    .alert(item: $alertId) { alert in
                        switch alert.id {
                        case .mustSignUpToMessage:
                            return Alert(title: Text("You Must Sign Up to Message \(buddyUsername)"), message: Text("Sign up only takes a minute, and we never ask for your email, phone number, or password."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Sign Up"), action: {
                                self.global.viewId = ViewId(id: .signUp)
                                self.global.signUpId = SignUpId(id: .selectInterests)
                            }))
                        case .mustSignUpToBlock:
                            return Alert(title: Text("You Must Sign Up to Block \(buddyUsername)"), message: Text("Sign up only takes a minute, and we never ask for your email, phone number, or password."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Sign Up"), action: {
                                self.global.viewId = ViewId(id: .signUp)
                                self.global.signUpId = SignUpId(id: .selectInterests)
                            }))
                        case .mustSignUpToReport:
                            return Alert(title: Text("You Must Sign Up to Report \(buddyUsername)"), message: Text("Sign up only takes a minute, and we never ask for your email, phone number, or password."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Sign Up"), action: {
                                self.global.viewId = ViewId(id: .signUp)
                                self.global.signUpId = SignUpId(id: .selectInterests)
                            }))
                        }
                    }
                )
        }
        .if(global.username != "") { content in
            content
                .navigationBarItems(trailing:
                    NavigationLink(destination: ChatRoomView(buddyUsername: buddyUsername)) {
                        Image(systemName: "text.bubble")
                            .imageScale(.large)
                    }
                )
        }
        .onAppear {
            self.fetchUser()
        }
    }
    
    func fetchUser() {
        let postString =
            "username=\(buddyUsername.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "hasImage=true"
        global.runPhp(script: "getOtherUser", postString: postString) { json in
            self.buddyImage = json["image"] as! String
            self.buddyGenderIndex = json["gender"] as! Int
            self.buddyBirthday = (json["birthday"] as! String).toDate(fromFormat: "yyyy-MM-dd", hasTime: false)
            self.buddyCountryIndex = json["country"] as! Int
            self.buddyInterests = json["interests"] as! String
            self.buddyLevelIndex = json["level"] as! Int
            self.buddyIntro = json["intro"] as! String
            self.buddyGitHub = json["gitHub"] as! String
            self.buddyLinkedIn = json["linkedIn"] as! String
            self.buddyLastVisit = (json["lastVisit"] as! String).toDate(fromFormat: "yyyy-MM-dd HH:mm:ss")
            self.buddyLastUpdate = (json["lastUpdate"] as! String).toDate(fromFormat: "yyyy-MM-dd HH:mm:ss")
            self.buddyAccountCreation = (json["accountCreation"] as! String).toDate(fromFormat: "yyyy-MM-dd HH:mm:ss")
            self.isReady = true
        }
    }
}

struct SearchProfileView_Previews: PreviewProvider {
    static var previews: some View {
        SearchProfileView(buddyUsername: "")
    }
}
