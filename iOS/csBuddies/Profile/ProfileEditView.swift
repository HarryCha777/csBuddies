//
//  ProfileEditView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/20/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase

struct ProfileEditView: View {
    @EnvironmentObject var global: Global
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentation
    
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
            mustBeAtLeast13,
            mustBeAtMost80,
            noSelectedInterests,
            tooLongOtherInterests,
            notGitHubUsername,
            tooLongGitHub,
            invalidGitHub,
            notLinkedInUrl,
            tooLongLinkedIn,
            invalidLinkedIn,
            tooShortIntro,
            tooLongIntro
        }
        var id: Id
    }

    @State var showImagePicker: Bool = false
    @State private var privateGender = false
    @State private var privateBirthday = false
    @State private var alertId: AlertId?

    var body: some View {
        Form {
            Section(header: Text("Image")) {
                Button(action: {
                    self.showImagePicker.toggle()
                }) {
                    HStack {
                        Spacer()
                        if global.editImage == "" {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 75, height: 75)
                                .clipShape(Circle())
                        } else {
                            Image(uiImage: global.editImage.toUiImage())
                                .resizable()
                                .frame(width: 75, height: 75)
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(sourceType: .photoLibrary) { uiImage in
                        self.global.editImage = self.global.toResizedString(uiImage: uiImage)
                    }
                }
                
                Button(action: {
                    self.global.editImage = ""
                }) {
                    Text("Remove Image")
                        .foregroundColor(Color.red)
                }
            }
            
            Section(header: Text("Gender")) {
                Picker("", selection: $global.editGenderIndex) {
                    ForEach(global.genderOptions.indices) { index in
                        if index != global.genderOptions.count - 1 {
                            Text(self.global.genderOptions[index])
                        }
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .disabled(global.editGenderIndex == global.genderOptions.count - 1)
                
                Button(action: {
                    if global.editGenderIndex == global.genderOptions.count - 1 {
                        global.editGenderIndex = global.genderOptions.count - 2
                    } else {
                        global.editGenderIndex = global.genderOptions.count - 1
                        privateGender = true
                    }
                }) {
                    HStack {
                        Text("I prefer not to say.")
                            .foregroundColor(colorScheme == .light ? Color.black : Color.white)
                        Spacer()
                        if global.editGenderIndex == global.genderOptions.count - 1 {
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
                .alert(isPresented: $privateGender) {
                    Alert(title: Text("Private Gender"), message: Text("Your profile will not be visible to users who filter by gender."), dismissButton: .default(Text("OK")))
                }
            }

            Section(header: Text("Birthday")) {
                Text("This is used to calculate your age.\nIt won't be shown to anyone.")
                
                DatePicker("Date Label", selection: $global.editBirthday, in: ...global.getUtcTime(), displayedComponents: .date)
                    .labelsHidden()
                    .disabled(global.editBirthday.toString(toFormat: "yyyy")[0] == "0")

                Button(action: {
                    if global.editBirthday.toString(toFormat: "yyyy")[0] == "0" {
                        global.editBirthday = global.getUtcTime()
                    } else {
                        var dateComponents = DateComponents()
                        dateComponents.year = 0
                        global.editBirthday = Calendar.current.date(from: dateComponents)!
                        privateBirthday = true
                    }
                }) {
                    HStack {
                        Text("I prefer not to say.")
                            .foregroundColor(colorScheme == .light ? Color.black : Color.white)
                        Spacer()
                        if global.editBirthday.toString(toFormat: "yyyy")[0] == "0" {
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
                .alert(isPresented: $privateBirthday) {
                    Alert(title: Text("Private Birthday"), message: Text("Your profile will not be visible to users who filter by age."), dismissButton: .default(Text("OK")))
                }
            }
            
            Section(header: Text("Country")) {
                Picker("Where do you live?", selection: $global.editCountryIndex) {
                    ForEach(global.countryOptions.indices) { index in
                        Text(self.global.countryOptions[index])
                    }
                }
            }
            
            Section(header: Text("Self-Introduction")) {
                MultilineTextField(minHeight: 300, introExample, text: Binding<String>(get: { self.global.editIntro }, set: {
                    self.global.editIntro = $0 } ))
            }
            
            Section(header: Text("Optional")) {
                HStack {
                    Text("GitHub Username:")
                    TextField("Just username, not URL.", text: $global.editGitHub)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                HStack {
                    Text("LinkedIn URL:")
                    TextField("Start with \"https://www.linkedin.com/\"", text: $global.editLinkedIn)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            
            Section(header: Text("Interests")) {
                NavigationLink(destination: ProfileEditInterestsView()) {
                    Text("Interests")
                }
                
                HStack {
                    Text("Others:")
                    TextField("Ex: R, Wix, Dart, Ruby, Flask, Django, Weebly, Desktop, Xamarin, Graphics, etc", text: $global.editOtherInterests)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Picker("", selection: $global.editLevelIndex) {
                    ForEach(global.levelOptions.indices) { index in
                        Text(self.global.levelOptions[index])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section(header: Text("Preview")) {
                Text("Preview may look different depending on the screen width of the viewer's device.")
                SearchProfileLinkView(searchProfileLinkData: SearchProfileLinkData(
                                        id: global.username,
                                        image: global.editImage,
                                        username: global.username,
                                        birthday: global.editBirthday,
                                        genderIndex: global.editGenderIndex,
                                        intro: global.editIntro,
                                        hasGitHub: global.editGitHub.count != 0,
                                        hasLinkedIn: global.editLinkedIn.count != 0))
                    .padding() // use padding to compensate for rounded list in search view
            }

            global.cancelButton(presentation: presentation)
            Button(action: {
                if self.global.editBirthday.toAge() < 13 {
                    self.alertId = AlertId(id: .mustBeAtLeast13)
                } else if self.global.editBirthday.toAge() > 80 &&
                    global.editBirthday.toString(toFormat: "yyyy")[0] != "0" {
                    self.alertId = AlertId(id: .mustBeAtMost80)
                } else if self.global.editInterests.count == 0 {
                    self.alertId = AlertId(id: .noSelectedInterests)
                } else if self.global.editOtherInterests.count > 100 {
                    self.alertId = AlertId(id: .tooLongOtherInterests)
                } else if self.global.editGitHub.contains("github.com") {
                    self.alertId = AlertId(id: .notGitHubUsername)
                } else if self.global.editGitHub.count > 39 {
                    self.alertId = AlertId(id: .tooLongGitHub)
                } else if !"https://github.com/\(self.global.editGitHub)".isValidUrl {
                    self.alertId = AlertId(id: .invalidGitHub)
                } else if self.global.editLinkedIn.count != 0 && !self.global.editLinkedIn.hasPrefix("https://www.linkedin.com/") {
                    self.alertId = AlertId(id: .notLinkedInUrl)
                } else if self.global.editLinkedIn.count > 100 {
                    self.alertId = AlertId(id: .tooLongLinkedIn)
                } else if self.global.editLinkedIn.count != 0 && !"\(self.global.editLinkedIn)".isValidUrl {
                    self.alertId = AlertId(id: .invalidLinkedIn)
                } else if self.global.editIntro.count < 100 {
                    self.alertId = AlertId(id: .tooShortIntro)
                } else if self.global.editIntro.count > 1000 {
                    self.alertId = AlertId(id: .tooLongIntro)
                } else {
                    self.updateUser()
                }
            }) {
                HStack {
                    Text("Update")
                        .alert(item: $alertId) { alert in
                            switch alert.id {
                            case .mustBeAtLeast13:
                                return Alert(title: Text("Younger Than 13"), message: Text("In order to comply with the Terms and Conditions, you must be at least 13."), dismissButton: .default(Text("OK")))
                            case .mustBeAtMost80:
                                return Alert(title: Text("Older Than 80"), message: Text("In order to be included in the age filter, you must be at most 80."), dismissButton: .default(Text("OK")))
                            case .noSelectedInterests:
                                return Alert(title: Text("No Interests Selected"), message: Text("Please select at least one interest."), dismissButton: .default(Text("OK")))
                            case .tooLongOtherInterests:
                                return Alert(title: Text("Too Long Other Interests"), message: Text("Your other interests must be no longer than 100 characters."), dismissButton: .default(Text("OK")))
                            case .notGitHubUsername:
                                return Alert(title: Text("Not a GitHub Username"), message: Text("Please type in only your GitHub username, not a URL."), dismissButton: .default(Text("OK")))
                            case .tooLongGitHub:
                                return Alert(title: Text("Too Long GitHub Username"), message: Text("Your GitHub username must be no longer than 39 characters."), dismissButton: .default(Text("OK")))
                            case .invalidGitHub:
                                return Alert(title: Text("Invalid GitHub Username"), message: Text("Your GitHub username must be either valid or left empty."), dismissButton: .default(Text("OK")))
                            case .notLinkedInUrl:
                                return Alert(title: Text("Not a LinkedIn URL"), message: Text("You should either leave your LinkedIn URL empty or make sure it begins with \"https://www.linkedin.com/\"."), dismissButton: .default(Text("OK")))
                            case .tooLongLinkedIn:
                                return Alert(title: Text("Too Long LinkedIn URL"), message: Text("Your LinkedIn URL must be no longer than 100 characters."), dismissButton: .default(Text("OK")))
                            case .invalidLinkedIn:
                                return Alert(title: Text("Invalid LinkedIn URL"), message: Text("Your LinkedIn URL must be either valid or left empty."), dismissButton: .default(Text("OK")))
                            case .tooShortIntro:
                                return Alert(title: Text("Your intro is too short."), message: Text("You currently typed \(self.global.editIntro.count) characters. Please write at least 100 characters."), dismissButton: .default(Text("OK")))
                            case .tooLongIntro:
                                return Alert(title: Text("Your intro is too long."), message: Text("You currently typed \(self.global.editIntro.count) characters. Please type no more than 1,000 characters."), dismissButton: .default(Text("OK")))
                            }
                    }
                }
            }
        }
        .navigationBarTitle("Edit Profile", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: global.cancelButton(presentation: presentation))
        .if(UIDevice.current.systemVersion[0...1] == "13") { content in
            content.modifier(AdaptsToKeyboard())
        }
    }
    
    func updateUser() {
        let postString =
            "username=\(global.username.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "password=\(global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "image=\(global.editImage.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "gender=\(global.editGenderIndex)&" +
            "birthday=\(global.editBirthday.toString(toFormat: "yyyy-MM-dd", hasTime: false))&" +
            "country=\(global.editCountryIndex)&" +
            "interests=\(global.editInterests.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "otherInterests=\(global.editOtherInterests.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "level=\(global.editLevelIndex)&" +
            "intro=\(global.editIntro.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "gitHub=\(global.editGitHub.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "linkedIn=\(global.editLinkedIn.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
        global.runPhp(script: "updateUser", postString: postString) { json in
            self.updateGlobalProfile()
            self.global.lastUpdate = self.global.getUtcTime()
            self.global.lastVisit = self.global.getUtcTime()
            self.presentation.wrappedValue.dismiss()
        }
    }

    func updateGlobalProfile() {
        global.image = global.editImage
        global.genderIndex = global.editGenderIndex
        global.birthday = global.editBirthday
        global.countryIndex = global.editCountryIndex
        global.interests = global.editInterests
        global.otherInterests = global.editOtherInterests
        global.levelIndex = global.editLevelIndex
        global.intro = global.editIntro
        global.gitHub = global.editGitHub
        global.linkedIn = global.editLinkedIn
    }
}
