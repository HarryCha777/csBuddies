//
//  SetUserProfileView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/16/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase

struct SetUserProfileView: View {
    @EnvironmentObject var global: Global

    @State private var mustVisitTypeIntro = false
    
    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            privateGender,
            privateBirthday,
            mustBeAtLeast13,
            mustBeAtMost130,
            notGitHubUsername,
            tooLongGitHub,
            invalidGitHub,
            notLinkedInProfileUrl,
            tooLongLinkedIn,
            invalidLinkedIn
    }
    
    var body: some View {
        ZStack {
            List {
                JoinStepperView(step: 2)
                
                Section(header: Text("Gender")) {
                    Picker("", selection: $global.genderIndex) {
                        ForEach(global.genderOptions.indices) { index in
                            if index != global.genderOptions.count - 1 {
                                Text(global.genderOptions[index])
                            }
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .disabled(global.genderIndex == global.genderOptions.count - 1)
                    
                    Button(action: {
                        if global.genderIndex == global.genderOptions.count - 1 {
                            global.genderIndex = global.genderOptions.count - 2
                        } else {
                            global.genderIndex = global.genderOptions.count - 1
                            activeAlert = .privateGender
                        }
                    }) {
                        HStack {
                            Text("I prefer not to say.")
                            Spacer()
                            if global.genderIndex == global.genderOptions.count - 1 {
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
                }
                
                Section(header: Text("Birthday")) {
                    Text("This is used to calculate your age.\nIt won't be shown to anyone.")
                    
                    DatePicker("Date Label", selection: $global.birthday, in: ...global.getUtcTime(), displayedComponents: .date)
                        .labelsHidden()
                        .disabled(global.birthday.toString()[0] == "0")
                    
                    Button(action: {
                        if global.birthday.toString()[0] == "0" {
                            global.birthday = global.getUtcTime()
                        } else {
                            var dateComponents = DateComponents()
                            dateComponents.year = 0
                            global.birthday = Calendar.current.date(from: dateComponents)!
                            activeAlert = .privateBirthday
                        }
                    }) {
                        HStack {
                            Text("I prefer not to say.")
                            Spacer()
                            if global.birthday.toString()[0] == "0" {
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
                }
                
                Section(header: Text("Country")) {
                    Picker("Where are you from?", selection: $global.countryIndex) {
                        ForEach(global.countryOptions.indices) { index in
                            Text(global.countryOptions[index])
                        }
                    }
                }
                
                Section(header: Text("Optional")) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("GitHub")
                        HStack(spacing: 0) {
                            Text("github.com/")
                            TextField("Username", text: $global.gitHub)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("LinkedIn")
                        HStack(spacing: 0) {
                            Text("linkedin.com/in/")
                            TextField("Profile URL", text: $global.linkedIn)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .removeHeaderPadding()

            NavigationLinkEmpty(destination: TypeIntroView(), isActive: $mustVisitTypeIntro)
        }
        .navigationBarTitle("Profile", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    if global.birthday.toAge() < 13 {
                        activeAlert = .mustBeAtLeast13
                    } else if global.birthday.toAge() > 130 &&
                                global.birthday.toString()[0] != "0" {
                        activeAlert = .mustBeAtMost130
                    } else if global.gitHub.contains("github.com") {
                        activeAlert = .notGitHubUsername
                    } else if global.gitHub.count > 39 {
                        activeAlert = .tooLongGitHub
                    } else if !"https://github.com/\(global.gitHub)".isValidUrl {
                        activeAlert = .invalidGitHub
                    } else if global.linkedIn.contains("linkedin.com") {
                        activeAlert = .notLinkedInProfileUrl
                    } else if global.linkedIn.count > 100 {
                        activeAlert = .tooLongLinkedIn
                    } else if !"https://www.linkedin.com/in/\(global.linkedIn)".isValidUrl {
                        activeAlert = .invalidLinkedIn
                    } else {
                        mustVisitTypeIntro = true
                    }
                }) {
                    Text("Next")
                }
            }
        }
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .privateGender:
                return Alert(title: Text("Private Gender"), message: Text("Your profile will not be visible to users who filter by gender."), dismissButton: .default(Text("OK")))
            case .privateBirthday:
                return Alert(title: Text("Private Birthday"), message: Text("Your profile will not be visible to users who filter by age."), dismissButton: .default(Text("OK")))
            case .mustBeAtLeast13:
                return Alert(title: Text("Younger Than 13"), message: Text("In order to comply with the Terms and Conditions, you must be at least 13."), dismissButton: .default(Text("OK")))
            case .mustBeAtMost130:
                return Alert(title: Text("Older Than 130"), message: Text("Not even the oldest person on Guinness World Records is over 130 years old."), dismissButton: .default(Text("OK")))
            case .notGitHubUsername:
                return Alert(title: Text("Not a GitHub Username"), message: Text("Please type in only your GitHub username, not a URL."), dismissButton: .default(Text("OK")))
            case .tooLongGitHub:
                return Alert(title: Text("Too Long GitHub Username"), message: Text("Your GitHub username must be no longer than 39 characters."), dismissButton: .default(Text("OK")))
            case .invalidGitHub:
                return Alert(title: Text("Invalid GitHub Username"), message: Text("Your GitHub username must be either valid or left empty."), dismissButton: .default(Text("OK")))
            case .notLinkedInProfileUrl:
                return Alert(title: Text("Not a LinkedIn Profile URL"), message: Text("Please type in only the rest of your LinkedIn URL, not the entire LinkedIn URL."), dismissButton: .default(Text("OK")))
            case .tooLongLinkedIn:
                return Alert(title: Text("Too Long LinkedIn URL"), message: Text("Your LinkedIn URL must be no longer than 100 characters."), dismissButton: .default(Text("OK")))
            case .invalidLinkedIn:
                return Alert(title: Text("Invalid LinkedIn URL"), message: Text("Your LinkedIn URL must be either valid or left empty."), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct SetUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        SetUserProfileView()
            .environmentObject(globalObject)
    }
}
