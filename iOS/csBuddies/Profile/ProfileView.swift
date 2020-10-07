//
//  ProfileView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/20/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var global: Global
    @Environment(\.colorScheme) var colorScheme
    
    @State private var mustVisitProfileEdit1 = false
    @State private var mustVisitProfileEdit2 = false
    
    var body: some View {
        NavigationView {
            if global.username == "" {
                VStack {
                    Text("You must sign up to have a profile.")
                    Spacer()
                        .frame(height: 50)
                    Text("Sign up only takes a minute, and we never ask for your email, phone number, or password.")
                    Spacer()
                        .frame(height: 10)
                    Button(action: {
                        self.global.viewId = ViewId(id: .signUp)
                        self.global.signUpId = SignUpId(id: .selectInterests)
                    }) {
                        Text("Click here to sign up!")
                    }
                    Spacer()
                }
                .padding()
                .navigationBarTitle("Profile")
            } else {
                List {
                    HStack {
                        VStack {
                            Spacer()
                            if global.image == "" {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 75, height: 75)
                                    .clipShape(Circle())
                            } else {
                                Image(uiImage: global.image.toUiImage())
                                    .resizable()
                                    .frame(width: 75, height: 75)
                                    .clipShape(Circle())
                            }
                            Spacer()
                        }
                
                        Spacer()
                            .frame(width: 15)
                
                        VStack(alignment: .leading) {
                            Text("\(global.username)")
                                .bold()
                                .font(.title)
                            HStack {
                                if global.genderIndex == 0 {
                                    Text("\(global.genderOptions[global.genderIndex])")
                                        .foregroundColor(Color.blue) +
                                        Text(",")
                                } else if global.genderIndex == 1 {
                                    Text("\(global.genderOptions[global.genderIndex])")
                                        .foregroundColor(Color(red: 255 / 255, green: 20 / 255, blue: 147 / 255)) + // pink
                                        Text(",")
                                } else if global.genderIndex == 2 ||
                                            global.genderIndex == 3 {
                                    Text("\(global.genderOptions[global.genderIndex])")
                                        .foregroundColor(Color.gray) +
                                        Text(",")
                                } else {
                                    Text("Unknown") +
                                        Text(",")
                                }
                                Text("\(global.birthday.toString(toFormat: "yyyy")[0] != "0" ? "\(global.birthday.toAge())" : "N/A")")
                            }
                            Text("\(global.countryOptions[safe: global.countryIndex] ?? "Unknown")")
                        }
                    }

                    Section(header: Text("Self-Introduction")) {
                        Text("\(global.intro)")
                        if global.gitHub != "" {
                            NavigationLink(destination:
                                WebView(request: URLRequest(url: URL(string: "https://www.github.com/\(self.global.gitHub)")!))
                                    .navigationBarTitle("GitHub", displayMode: .inline)
                            ) {
                                Image("gitHubLogo")
                                    .resizable()
                                    .frame(width: 22, height: 22)
                                    .if(colorScheme == .dark) { content in
                                        content.colorInvert() // invert color on dark mode
                                    }
                                Text("https://www.github.com/\(self.global.gitHub)")
                                    .foregroundColor(Color.blue)
                            }
                        }
                        if global.linkedIn != "" {
                            NavigationLink(destination:
                                WebView(request: URLRequest(url: URL(string: "\(self.global.linkedIn)")!))
                                    .navigationBarTitle("LinkedIn", displayMode: .inline)
                            ) {
                                Image("linkedInLogo")
                                    .resizable()
                                    .frame(width: 22, height: 22)
                                Text("\(self.global.linkedIn)")
                                    .foregroundColor(Color.blue)
                            }
                        }
                    }
                
                    Section(header: Text("Interests")) {
                        if global.interests.count == 0 {
                            Text("Did not select any interest.")
                        } else {
                            Text("\(global.interests.toReadableInterests())")
                        }
                        HStack {
                            Text("Level")
                            Spacer()
                            Text("\(global.levelOptions[safe: global.levelIndex] ?? "Unknown")")
                        }
                    }
                
                    // Since the users are not very active yet, last visit may discourage new users from messaging old users.
                    // Uncomment the Activity section only when the app is more active so that new users will get encouraged to see other users' last visit.
                    // Mark "Today" and "Yesterday" in text.
                    /*Section(header: Text("Activity")) {
                        HStack {
                            Text("Last Visit")
                            Spacer()
                            Text("\(global.lastVisit.toLocal().toString(toFormat: "M/d/yy"))")
                        }
                        HStack {
                            Text("Last Update")
                            Spacer()
                            Text("\(global.lastUpdate.toLocal().toString(toFormat: "M/d/yy"))")
                        }
                        HStack {
                            Text("Account Created")
                            Spacer()
                            Text("\(global.accountCreation.toLocal().toString(toFormat: "M/d/yy"))")
                        }
                    }*/
                
                    Section(header: Text("Preview")) {
                        SearchProfileLinkView(searchProfileLinkData: SearchProfileLinkData(
                                                id: global.username,
                                                image: global.image,
                                                username: global.username,
                                                birthday: global.birthday,
                                                genderIndex: global.genderIndex,
                                                intro: global.intro,
                                                hasGitHub: global.gitHub.count != 0,
                                                hasLinkedIn: global.linkedIn.count != 0))
                    }
                
                    Section(header: Text("Action")) {
                        ZStack(alignment: .leading) {
                            Button(action: {
                                self.setEditVars()
                                self.mustVisitProfileEdit1 = true
                            }) {
                                Text("Edit Profile")
                                    .foregroundColor(Color.blue)
                            }
                
                            NavigationLink(destination: ProfileEditView(), isActive: self.$mustVisitProfileEdit1) {
                                EmptyView()
                            }
                        }
                    }
                }
                .roundCorners()
                .navigationBarTitle("Profile")
                .navigationBarItems(trailing:
                    ZStack {
                        Button(action: {
                            self.setEditVars()
                            self.mustVisitProfileEdit2 = true
                        }) {
                            Image(systemName: "square.and.pencil")
                                .imageScale(.large)
                        }
                
                        NavigationLink(destination: ProfileEditView(), isActive: self.$mustVisitProfileEdit2) {
                            EmptyView()
                        }
                    }
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // Reset edit variables here instead of on appear of Profile Edit View since it may be navigated from other views.
    func setEditVars() {
        global.editImage = global.image
        global.editGenderIndex = global.genderIndex
        global.editBirthday = global.birthday
        global.editCountryIndex = global.countryIndex
        global.editInterests = global.interests
        global.editOtherInterests = global.otherInterests
        global.editLevelIndex = global.levelIndex
        global.editIntro = global.intro
        global.editGitHub = global.gitHub
        global.editLinkedIn = global.linkedIn
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
