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
    
    @State private var isRefreshing = false
    
    @State var activeSheet: Sheets?
    enum Sheets: Identifiable {
        var id: Int { self.hashValue }
        case
            profileEdit
    }

    var body: some View {
        VStack {
            if global.myId == "" {
                SimpleView(
                    lottieView: LottieView(name: "team", size: 300, mustLoop: true),
                    subtitle: "Join us to build your profile. You only need an email, and we'll send you a magic link!",
                    bottomView: AnyView(Button(action: {
                        global.activeRootView = .join
                    }) {
                        global.blueButton(title: "Get Magic Link")
                    }))
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            HStack { // Having at least 2 views inside HStack is necessary to make Image larger.
                                Spacer()
                                NavigationLink(destination: ProfileSettingsView()) {
                                    Image(systemName: "gear")
                                        .font(.largeTitle)
                                }
                            }
                        }
                    }
            } else {
                BuddiesProfileContentView(
                    userProfileData: UserProfileData(
                        userId: global.myId,
                        username: global.username,
                        genderIndex: global.genderIndex,
                        birthday: global.birthday,
                        countryIndex: global.countryIndex,
                        interests: global.interests,
                        intro: global.intro,
                        gitHub: global.gitHub,
                        linkedIn: global.linkedIn,
                        isOnline: true,
                        lastVisitTime: global.getUtcTime(),
                        bytesMade: global.bytesMade,
                        likesReceived: global.likesReceived,
                        likesGiven: global.likesGiven),
                    isRefreshing: isRefreshing)
                    .pullToRefresh(isShowing: $isRefreshing) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Wait for BuddiesProfileContentView to notice that it must refresh.
                            isRefreshing = false
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            HStack {
                                Button(action: {
                                    setEditVars()
                                    activeSheet = .profileEdit
                                }) {
                                    Image(systemName: "person.crop.circle")
                                        .font(.largeTitle)
                                }

                                NavigationLink(destination: ProfileSettingsView()) {
                                    Image(systemName: "gear")
                                        .font(.largeTitle)
                                }
                            }
                        }
                    }
            }
        }
        .navigationBarTitle("Profile")
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .profileEdit:
                NavigationView {
                    ProfileEditView()
                        .environmentObject(globalObject)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }
    
    // Reset edit variables here instead of onAppear of ProfileEditView since it may be navigated from other views.
    func setEditVars() {
        global.newSmallImage = global.smallImage
        global.newBigImage = global.bigImage
        global.newGenderIndex = global.genderIndex
        global.newBirthday = global.birthday
        global.newCountryIndex = global.countryIndex
        global.newInterests = global.interests
        global.newOtherInterests = global.otherInterests
        global.newIntro = global.intro
        global.newGitHub = global.gitHub
        global.newLinkedIn = global.linkedIn
    }
}
