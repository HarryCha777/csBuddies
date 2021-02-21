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
    
    @Binding var mustUpdateProfile: Bool
    
    private let introExample =
        "Example:\n" +
        "Hello everybody! My name's Bob.\n" +
        "I'm a college student studying Computer Science in the US.\n\n" +
        "My favorite programming language is C#, and I use it to program video games on Unity3D.\n" +
        "You can check out some of my games on my GitHub profile.\n" +
        "Thanks for reading!"
    
    @State private var newSmallImage = globalObject.smallImage
    @State private var newBigImage = globalObject.bigImage
    @State private var newGenderIndex = globalObject.genderIndex
    @State private var newBirthday = globalObject.birthday
    @State private var newCountryIndex = globalObject.countryIndex
    @State private var newGitHub = globalObject.github
    @State private var newLinkedIn = globalObject.linkedin
    @State private var newInterests = globalObject.interests
    @State private var newOtherInterests = globalObject.otherInterests
    @State private var newIntro = globalObject.intro
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
        List {
            Section(header: Text("Image")) {
                Button(action: {
                    activeSheet = .imagePicker
                }) {
                    HStack {
                        Spacer()
                        SmallImageView(userId: global.myId, isOnline: false, size: 75, isUpdating: true, newSmallImage: newSmallImage)
                        Spacer()
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Section(header: Text("Gender")) {
                Picker("", selection: $newGenderIndex) {
                    ForEach(global.genderOptions.indices) { index in
                        if index != global.genderOptions.count - 1 {
                            Text(global.genderOptions[index])
                        }
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .disabled(newGenderIndex == global.genderOptions.count - 1)
                
                Button(action: {
                    if newGenderIndex == global.genderOptions.count - 1 {
                        newGenderIndex = global.genderOptions.count - 2
                    } else {
                        newGenderIndex = global.genderOptions.count - 1
                        activeAlert = .privateGender
                    }
                }) {
                    HStack {
                        Text("I prefer not to say.")
                        Spacer()
                        if newGenderIndex == global.genderOptions.count - 1 {
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
                
                DatePicker("Date Label", selection: $newBirthday, in: ...global.getUtcTime(), displayedComponents: .date)
                    .labelsHidden()
                    .disabled(newBirthday.toString()[0] == "0")
                
                Button(action: {
                    if newBirthday.toString()[0] == "0" {
                        newBirthday = global.getUtcTime()
                    } else {
                        var dateComponents = DateComponents()
                        dateComponents.year = 0
                        newBirthday = Calendar.current.date(from: dateComponents)!
                        activeAlert = .privateBirthday
                    }
                }) {
                    HStack {
                        Text("I prefer not to say.")
                        Spacer()
                        if newBirthday.toString()[0] == "0" {
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
                Picker("Where are you from?", selection: $newCountryIndex) {
                    ForEach(global.countryOptions.indices) { index in
                        Text(global.countryOptions[index])
                    }
                }
            }
            
            Section(header: Text("Self-Introduction")) {
                VStack {
                    BetterTextEditor(placeholder: introExample, text: $newIntro)
                    Spacer()
                    HStack {
                        Spacer()
                        Text("\(newIntro.count)/256")
                            .padding()
                            .foregroundColor(newIntro.count > 256 ? .red : colorScheme == .light ? .black : .white)
                    }
                }
            }
            
            Section(header: Text("Optional")) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("GitHub")
                    HStack(spacing: 0) {
                        Text("github.com/")
                        TextField("Username", text: $newGitHub)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                    }
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("LinkedIn")
                    HStack(spacing: 0) {
                        Text("linkedin.com/in/")
                        TextField("Profile URL", text: $newLinkedIn)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                    }
                }
            }
            
            Section(header: Text("Interests")) {
                NavigationLink(
                    destination:
                        List {
                            InterestsView(interests: $newInterests)
                                .environmentObject(globalObject)
                        }
                        .listStyle(PlainListStyle())
                        .navigationBarTitle("Edit Interests", displayMode: .inline)
                ) {
                    if newInterests.count == 0 {
                        Text("Interests")
                    } else {
                        TagsView(data: newInterests) { interest in
                            InterestsButtonDisabledView(interest: interest, interests: newInterests)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("Others")
                    TextField("Ex: Design, Desktop, Graphics, etc", text: $newOtherInterests)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .disabledOnLoad(isLoading: isUpdating)
        .navigationBarTitle("Edit Profile", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                BackButton(title: "Cancel", presentation: presentation)
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    isUpdating = true
                    
                    if newSmallImage == "" {
                        activeAlert = .noImage
                    } else if newBirthday.toAge() < 13 {
                        activeAlert = .mustBeAtLeast13
                    } else if newBirthday.toAge() > 130 &&
                                newBirthday.toString()[0] != "0" {
                        activeAlert = .mustBeAtMost130
                    } else if newOtherInterests.count > 100 {
                        activeAlert = .tooLongOtherInterests
                    } else if newGitHub.contains("github.com") {
                        activeAlert = .notGitHubUsername
                    } else if newGitHub.count > 39 {
                        activeAlert = .tooLongGitHub
                    } else if !"https://github.com/\(newGitHub)".isValidUrl {
                        activeAlert = .invalidGitHub
                    } else if newLinkedIn.contains("linkedin.com") {
                        activeAlert = .notLinkedInProfileUrl
                    } else if newLinkedIn.count > 100 {
                        activeAlert = .tooLongLinkedIn
                    } else if !"https://www.linkedin.com/in/\(newLinkedIn)".isValidUrl {
                        activeAlert = .invalidLinkedIn
                    } else if newIntro == "" {
                        activeAlert = .blankIntro
                    } else if newIntro.count > 256 {
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
                    newSmallImage = global.toResizedString(uiImage: uiImage, maxSize: 200.0)
                    newBigImage = global.toResizedString(uiImage: uiImage, maxSize: 1000.0)
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
                return Alert(title: Text("Your intro is too long."), message: Text("You currently typed \(newIntro.count) characters. Please type no more than 256 characters."), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func didNotEdit() -> Bool {
        if global.smallImage == newSmallImage &&
            global.bigImage == newBigImage &&
            global.genderIndex == newGenderIndex &&
            global.birthday == newBirthday &&
            global.countryIndex == newCountryIndex &&
            global.interests == newInterests &&
            global.otherInterests == newOtherInterests &&
            global.intro == newIntro &&
            global.github == newGitHub &&
            global.linkedin == newLinkedIn {
            return true
        }
        return false
    }
    
    func updateUser() {
        global.firebaseUser!.getIDToken(completion: { (token, error) in
            let postString =
                "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "smallImage=\(newSmallImage.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "bigImage=\(newBigImage.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "gender=\(newGenderIndex)&" +
                "birthday=\(newBirthday.toString(toFormat: "yyyy-MM-dd"))&" +
                "country=\(newCountryIndex)&" +
                "interests=\(newInterests.toInterestsString().addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "otherInterests=\(newOtherInterests.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "intro=\(newIntro.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "github=\(newGitHub.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "linkedin=\(newLinkedIn.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
            global.runPhp(script: "updateUser", postString: postString) { json in
                updateGlobalProfile()
                
                mustUpdateProfile = true
                presentation.wrappedValue.dismiss()
                global.confirmationText = "Updated"
            }
        })
    }
    
    func updateGlobalProfile() {
        global.smallImage = newSmallImage
        global.bigImage = newBigImage
        global.genderIndex = newGenderIndex
        global.birthday = newBirthday
        global.countryIndex = newCountryIndex
        global.interests = newInterests
        global.otherInterests = newOtherInterests
        global.intro = newIntro
        global.github = newGitHub
        global.linkedin = newLinkedIn
    }
}
