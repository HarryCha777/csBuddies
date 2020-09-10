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
    
    var body: some View {
        Form {
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
                        Text("\(global.genderOptions[safe: buddyGenderIndex] ?? "Unknown"), \(buddyBirthday.toAge())")
                        Text("\(global.countryOptions[safe: buddyCountryIndex] ?? "Unknown")")
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
                
                Section(header: Text("Activity")) {
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
                }
                
                Section(header: Text("Action")) {
                    ZStack(alignment: .leading) {
                        Text("Message User")
                            .foregroundColor(Color.blue)
                        
                        // Hide navigation link arrow by making invisible navigation link in ZStack.
                        NavigationLink(destination: ChatRoomView(buddyUsername: buddyUsername)) {
                            EmptyView()
                        }
                        .hidden()
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
                        .hidden()
                    }
                    
                }
            }
        }
        .roundCorners()
        .navigationBarTitle("\(buddyUsername)", displayMode: .inline)
        .navigationBarItems(trailing:
            NavigationLink(destination: ChatRoomView(buddyUsername: buddyUsername)) {
                Image(systemName: "text.bubble")
                    .imageScale(.large)
            }
        )
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
