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
    
    var body: some View {
        NavigationView {
            Form {
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
                        Text("\(global.genderOptions[safe: global.genderIndex] ?? "Unknown"), \(global.birthday.toAge())")
                        Text("\(global.countryOptions[safe: global.countryIndex] ?? "Unknown")")
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
                
                Section(header: Text("Activity")) {
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
                }
            }
            .roundCorners()
            .navigationBarTitle("Profile")
            .navigationBarItems(trailing:
                NavigationLink(destination: ProfileEditView()) {
                    Image(systemName: "square.and.pencil")
                        .imageScale(.large)
                }
            )
            .onAppear {
                self.setEditVars()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // needed so screen works on iPad
    }
    
    // Reset edit variables here instead of on appear of Profile Edit View since it may be navigated from views within itself.
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
