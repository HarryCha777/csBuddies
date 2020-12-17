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
            "Hello everybody! My name's Bob.\n" +
            "I'm a college student studying Computer Science in the US.\n\n" +
            "My favorite programming language is C#, and I use it to program video games on Unity3D.\n" +
            "You can check out some of my games on my GitHub profile.\n" +
            "Thanks for reading!"

    @State private var isUpdating = false

    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            noImage,
            privateGender,
            privateBirthday,
            mustBeAtLeast13,
            mustBeAtMost130,
            tooLongOtherInterests,
            notGitHubUsername,
            tooLongGitHub,
            invalidGitHub,
            notLinkedInProfileUrl,
            tooLongLinkedIn,
            invalidLinkedIn,
            blankIntro,
            tooLongIntro
    }

    @State var activeSheet: Sheets?
    enum Sheets: Identifiable {
        var id: Int { self.hashValue }
        case
            imagePicker
    }
    
    var body: some View {
        ZStack {
            List {
                Section(header: Text("Image")) {
                    Button(action: {
                        activeSheet = .imagePicker
                    }) {
                        HStack {
                            Spacer()
                            SmallImageView(userId: global.myId, isOnline: false, size: 75, myImage: global.newSmallImage)
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            
                Section(header: Text("Gender")) {
                    Picker("", selection: $global.newGenderIndex) {
                        ForEach(global.genderOptions.indices) { index in
                            if index != global.genderOptions.count - 1 {
                                Text(global.genderOptions[index])
                            }
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .disabled(global.newGenderIndex == global.genderOptions.count - 1)
            
                    Button(action: {
                        if global.newGenderIndex == global.genderOptions.count - 1 {
                            global.newGenderIndex = global.genderOptions.count - 2
                        } else {
                            global.newGenderIndex = global.genderOptions.count - 1
                            activeAlert = .privateGender
                        }
                    }) {
                        HStack {
                            Text("I prefer not to say.")
                            Spacer()
                            if global.newGenderIndex == global.genderOptions.count - 1 {
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
            
                    DatePicker("Date Label", selection: $global.newBirthday, in: ...global.getUtcTime(), displayedComponents: .date)
                        .labelsHidden()
                        .disabled(global.newBirthday.toString()[0] == "0")

                    Button(action: {
                        if global.newBirthday.toString()[0] == "0" {
                            global.newBirthday = global.getUtcTime()
                        } else {
                            var dateComponents = DateComponents()
                            dateComponents.year = 0
                            global.newBirthday = Calendar.current.date(from: dateComponents)!
                            activeAlert = .privateBirthday
                        }
                    }) {
                        HStack {
                            Text("I prefer not to say.")
                            Spacer()
                            if global.newBirthday.toString()[0] == "0" {
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
                    Picker("Where are you from?", selection: $global.newCountryIndex) {
                        ForEach(global.countryOptions.indices) { index in
                            Text(global.countryOptions[index])
                        }
                    }
                }
            
                Section(header: Text("Self-Introduction")) {
                    VStack {
                        BetterTextEditor(placeholder: introExample, text: $global.newIntro)
                        Spacer()
                        HStack {
                            Spacer()
                            Text("\(global.newIntro.count)/256")
                                .padding()
                                .foregroundColor(global.newIntro.count > 256 ? Color.red : colorScheme == .light ? Color.black : Color.white)
                        }
                    }
                }
            
                Section(header: Text("Optional")) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("GitHub")
                        HStack(spacing: 0) {
                            Text("github.com/")
                            TextField("Username", text: $global.newGitHub)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                        }
                    }
            
                    VStack(alignment: .leading, spacing: 3) {
                        Text("LinkedIn")
                        HStack(spacing: 0) {
                            Text("linkedin.com/in/")
                            TextField("Profile URL", text: $global.newLinkedIn)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                        }
                    }
                }
            
                Section(header: Text("Interests")) {
                    NavigationLink(
                        destination:
                            List {
                                InterestsView(interests: $global.newInterests)
                                    .environmentObject(globalObject)
                            }
                            .listStyle(PlainListStyle())
                            .navigationBarTitle("Edit Interests", displayMode: .inline)
                    ) {
                        if global.newInterests.count == 0 {
                            Text("Interests")
                        } else {
                            TagsView(
                                data: global.newInterests
                            ) { interest in
                                InterestsButtonDisabledView(interest: interest, interests: global.newInterests)
                            }
                        }
                    }
            
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Others")
                        TextField("Ex: Design, Desktop, Graphics, etc", text: $global.newOtherInterests)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
            
                Section(header: Text("Preview")) {
                    Text("Preview depends on the screen width.")
                    BuddiesPreviewView(userPreviewData: UserPreviewData(
                                            userId: global.myId,
                                            username: global.username,
                                            birthday: global.newBirthday,
                                            genderIndex: global.newGenderIndex,
                                            intro: global.newIntro,
                                            hasGitHub: global.newGitHub.count != 0,
                                            hasLinkedIn: global.newLinkedIn.count != 0,
                                            isOnline: true,
                                            lastVisitTime: global.getUtcTime()),
                                    myImage: global.newSmallImage)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .disabled(isUpdating)
            .opacity(isUpdating ? 0.3 : 1)
            
            if isUpdating {
                LottieView(name: "load", size: 300, mustLoop: true)
            }
        }
        .navigationBarTitle("Edit Profile", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                global.backButton(presentation: presentation, title: "Cancel")
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    isUpdating = true
                    
                    if global.newSmallImage == "" {
                        activeAlert = .noImage
                    } else if global.newBirthday.toAge() < 13 {
                        activeAlert = .mustBeAtLeast13
                    } else if global.newBirthday.toAge() > 130 &&
                        global.newBirthday.toString()[0] != "0" {
                        activeAlert = .mustBeAtMost130
                    } else if global.newOtherInterests.count > 100 {
                        activeAlert = .tooLongOtherInterests
                    } else if global.newGitHub.contains("github.com") {
                        activeAlert = .notGitHubUsername
                    } else if global.newGitHub.count > 39 {
                        activeAlert = .tooLongGitHub
                    } else if !"https://github.com/\(global.newGitHub)".isValidUrl {
                        activeAlert = .invalidGitHub
                    } else if global.newLinkedIn.contains("linkedin.com") {
                        activeAlert = .notLinkedInProfileUrl
                    } else if global.newLinkedIn.count > 100 {
                        activeAlert = .tooLongLinkedIn
                    } else if !"https://www.linkedin.com/in/\(global.newLinkedIn)".isValidUrl {
                        activeAlert = .invalidLinkedIn
                    } else if global.newIntro == "" {
                        activeAlert = .blankIntro
                    } else if global.newIntro.count > 256 {
                        activeAlert = .tooLongIntro
                    } else if didNotEdit() {
                        presentation.wrappedValue.dismiss()
                        global.confirmationText = "Updated"
                    } else {
                        updateUser()
                    }
                }) {
                    Text("Update")
                }
                .disabled(isUpdating)
            }
        }
        .sheet(item: $activeSheet) { sheet in
            // ImagePickerView should not be inside NavigationView.
            switch sheet {
            case .imagePicker:
                ImagePickerView(sourceType: .photoLibrary) { uiImage in
                    global.newSmallImage = global.toResizedString(uiImage: uiImage, maxSize: 200.0)
                    global.newBigImage = global.toResizedString(uiImage: uiImage, maxSize: 1000.0)
                }
                .environmentObject(globalObject)
            }
        }
        .alert(item: $activeAlert) { alert in
            DispatchQueue.main.async {
                isUpdating = false
            }
            
            switch alert {
            case .noImage:
                return Alert(title: Text("You didn't choose an image."), message: Text("Please upload a profile image."), dismissButton: .default(Text("OK")))
            case .privateGender:
                return Alert(title: Text("Private Gender"), message: Text("Your profile will not be visible to users who filter by gender."), dismissButton: .default(Text("OK")))
            case .privateBirthday:
                return Alert(title: Text("Private Birthday"), message: Text("Your profile will not be visible to users who filter by age."), dismissButton: .default(Text("OK")))
            case .mustBeAtLeast13:
                return Alert(title: Text("Younger Than 13"), message: Text("In order to comply with the Terms and Conditions, you must be at least 13."), dismissButton: .default(Text("OK")))
            case .mustBeAtMost130:
                return Alert(title: Text("Older Than 130"), message: Text("Not even the oldest person on Guinness World Records is over 130 years old."), dismissButton: .default(Text("OK")))
            case .tooLongOtherInterests:
                return Alert(title: Text("Too Long Other Interests"), message: Text("Your other interests must be no longer than 100 characters."), dismissButton: .default(Text("OK")))
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
            case .blankIntro:
                return Alert(title: Text("Your intro is blank."), message: Text("Your intro cannot be blank."), dismissButton: .default(Text("OK")))
            case .tooLongIntro:
                return Alert(title: Text("Your intro is too long."), message: Text("You currently typed \(global.newIntro.count) characters. Please type no more than 256 characters."), dismissButton: .default(Text("OK")))
            }
    }
    }
    
    func didNotEdit() -> Bool {
        if global.smallImage == global.newSmallImage &&
            global.bigImage == global.newBigImage &&
            global.genderIndex == global.newGenderIndex &&
            global.birthday == global.newBirthday &&
            global.countryIndex == global.newCountryIndex &&
            global.interests == global.newInterests &&
            global.otherInterests == global.newOtherInterests &&
            global.intro == global.newIntro &&
            global.gitHub == global.newGitHub &&
            global.linkedIn == global.newLinkedIn {
            return true
        }
        return false
    }

    func updateUser() {
        let postString =
            "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "password=\(global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "smallImage=\(global.newSmallImage.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "bigImage=\(global.newBigImage.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "gender=\(global.newGenderIndex)&" +
            "birthday=\(global.newBirthday.toString(toFormat: "yyyy-MM-dd"))&" +
            "country=\(global.newCountryIndex)&" +
            "interests=\(global.newInterests.toInterestsString().addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "otherInterests=\(global.newOtherInterests.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "intro=\(global.newIntro.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "gitHub=\(global.newGitHub.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "linkedIn=\(global.newLinkedIn.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
        global.runPhp(script: "updateUser", postString: postString) { json in
            updateGlobalProfile()
            
            presentation.wrappedValue.dismiss()
            global.confirmationText = "Updated"
        }
    }

    func updateGlobalProfile() {
        global.smallImage = global.newSmallImage
        global.bigImage = global.newBigImage
        global.genderIndex = global.newGenderIndex
        global.birthday = global.newBirthday
        global.countryIndex = global.newCountryIndex
        global.interests = global.newInterests
        global.otherInterests = global.newOtherInterests
        global.intro = global.newIntro
        global.gitHub = global.newGitHub
        global.linkedIn = global.newLinkedIn
    }
}
