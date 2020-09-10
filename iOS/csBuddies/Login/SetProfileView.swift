//
//  SetProfileView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/16/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase

struct SetProfileView: View {
    @EnvironmentObject var global: Global
    
    private struct AlertId: Identifiable {
        enum Id {
            case
            mustBeAtLeast13,
            notGitHubUsername,
            tooLongGitHub,
            invalidGitHub,
            notLinkedInUrl,
            tooLongLinkedIn,
            invalidLinkedIn
        }
        var id: Id
    }
    
    @State private var alertId: AlertId?
    
    var body: some View {
        NavigationView {
            Form {
                Text("You're almost done!\n" +
                    "Please set up your profile.")
                
                Section(header: Text("Gender")) {
                    Picker("", selection: $global.genderIndex) {
                        ForEach(global.genderOptions.indices) { index in
                            Text(self.global.genderOptions[index])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Birthday")) {
                    Text("This is used to calculate your age.\nIt won't be shown to anyone.")
                    
                    DatePicker("Date Label", selection: $global.birthday, in: ...global.getUtcTime(), displayedComponents: .date)
                        .labelsHidden()
                }
                
                Section(header: Text("Country")) {
                    Picker("Where do you live?", selection: $global.countryIndex) {
                        ForEach(global.countryOptions.indices) { index in
                            Text(self.global.countryOptions[index])
                        }
                    }
                }
                
                // When the new users are allowed to check out the app before making an account,
                // uncomment the code below and also let users upload a profile image.
                /*Section(header: Text("Optional")) {
                    Text("If you'd like to show off your code, feel free to include your GitHub username.")
                    
                    HStack {
                        Text("GitHub Username:")
                        TextField("Just username, not URL.", text: $global.gitHub)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Text("If you'd like to show more about you, try pasting your LinkedIn profile URL here.")
                    
                    HStack {
                        Text("LinkedIn URL:")
                        TextField("Start with \"https://www.linkedin.com/\"", text: $global.linkedIn)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }*/
                
                Button(action: {
                    if self.global.birthday.toAge() < 13 {
                        self.alertId = AlertId(id: .mustBeAtLeast13)
                    } else if self.global.gitHub.contains("github.com") {
                        self.alertId = AlertId(id: .notGitHubUsername)
                    } else if self.global.gitHub.count > 39 {
                        self.alertId = AlertId(id: .tooLongGitHub)
                    } else if !"https://github.com/\(self.global.gitHub)".isValidUrl {
                        self.alertId = AlertId(id: .invalidGitHub)
                    } else if self.global.linkedIn.count != 0 && !self.global.linkedIn.hasPrefix("https://www.linkedin.com/") {
                        self.alertId = AlertId(id: .notLinkedInUrl)
                    } else if self.global.linkedIn.count > 100 {
                        self.alertId = AlertId(id: .tooLongLinkedIn)
                    } else if self.global.linkedIn.count != 0 && !"\(self.global.linkedIn)".isValidUrl {
                        self.alertId = AlertId(id: .invalidLinkedIn)
                    } else {
                        self.global.isSettingProfile = false
                    }
                }) {
                    HStack {
                        Text("Set This Profile")
                            .alert(item: $alertId) { alert in
                                switch alert.id {
                                case .mustBeAtLeast13:
                                    return Alert(title: Text("Younger Than 13"), message: Text("In order to comply with the Terms and Conditions, you must be at least 13."), dismissButton: .default(Text("OK")))
                                case .notGitHubUsername:
                                    return Alert(title: Text("Not a GitHub Username"), message: Text("Please type in only your GitHub username, not a URL."), dismissButton: .default(Text("OK")))
                                case .tooLongGitHub:
                                    return Alert(title: Text("Too Long GitHub Username"), message: Text("Your GitHub username must be no longer than 39 characters."), dismissButton: .default(Text("OK")))
                                case .invalidGitHub:
                                    return Alert(title: Text("Invalid GitHub Username"), message: Text("Your GitHub Username must be either valid or left empty."), dismissButton: .default(Text("OK")))
                                case .notLinkedInUrl:
                                    return Alert(title: Text("Not a LinkedIn URL"), message: Text("You should either leave your LinkedIn URL empty or make sure it begins with \"https://www.linkedin.com/\"."), dismissButton: .default(Text("OK")))
                                case .tooLongLinkedIn:
                                    return Alert(title: Text("Too Long LinkedIn URL"), message: Text("Your LinkedIn URL must be no longer than 100 characters."), dismissButton: .default(Text("OK")))
                                case .invalidLinkedIn:
                                    return Alert(title: Text("Invalid LinkedIn URL"), message: Text("Your LinkedIn URL must be either valid or left empty."), dismissButton: .default(Text("OK")))
                                }
                            }
                    }
                }

            }
            .navigationBarTitle("Profile")
            .modifier(AdaptsToKeyboard())
        }
        .navigationViewStyle(StackNavigationViewStyle()) // needed so screen works on iPad
    }
}

struct SetProfileView_Previews: PreviewProvider {
    static var previews: some View {
        SetProfileView()
            .environmentObject(Global())
    }
}
