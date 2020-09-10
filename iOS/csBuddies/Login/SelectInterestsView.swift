//
//  SelectInterestsView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/16/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct SelectInterestsView: View {
    @EnvironmentObject var global: Global
    
    private struct AlertId: Identifiable {
        enum Id {
            case
            noSelectedInterests,
            tooLongOtherInterests
        }
        var id: Id
    }
    
    @State private var isReady = false
    @State private var isSelectedList = [Bool]()
    @State private var alertId: AlertId?
    
    var body: some View {
        NavigationView {
            Form {
                if isReady {
                    Text("Choose anything you like!\n" +
                        "Don't worry, you can change these any time.")
                    
                    Section(header: Text("Languages")) {
                        ForEach(global.interestsOptions.indices) { index in
                            // The list gets mixed up when scrolled too quickly if there are more than one section, so set boundaries for index.
                            if index < 12 {
                                Toggle(isOn: self.$isSelectedList[index]) {
                                    Text("\(self.global.interestsOptions[index])")
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Topics")) {
                        ForEach(global.interestsOptions.indices) { index in
                            if 12 <= index && index < 12 + 9 {
                                Toggle(isOn: self.$isSelectedList[index]) {
                                    Text("\(self.global.interestsOptions[index])")
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Tools")) {
                        ForEach(global.interestsOptions.indices) { index in
                            if 12 + 9 <= index {
                                Toggle(isOn: self.$isSelectedList[index]) {
                                    Text("\(self.global.interestsOptions[index])")
                                }
                            }
                        }
                    }

                    Section(header: Text("Others")) {
                        TextField("Ex: R, Wix, Dart, Ruby, Flask, Django, Weebly, Desktop, Xamarin, Graphics, etc", text: $global.otherInterests)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Section(header: Text("Your Level")) {
                        Picker("", selection: $global.levelIndex) {
                            ForEach(global.levelOptions.indices) { index in
                                Text(self.global.levelOptions[index])
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    Button(action: {
                        if self.isSelectedList.toInterests().count == 0 {
                            self.alertId = AlertId(id: .noSelectedInterests)
                        } else if self.global.otherInterests.count > 100 {
                            self.alertId = AlertId(id: .tooLongOtherInterests)
                        } else {
                            self.global.interests = self.isSelectedList.toInterests()
                            self.global.isSelectingInterests = false
                        }
                    }) {
                        Text("Select These Interests")
                            .alert(item: $alertId) { alert in
                                switch alert.id {
                                case .noSelectedInterests:
                                    return Alert(title: Text("No Interests Selected"), message: Text("Please select at least one interest."), dismissButton: .default(Text("OK")))
                                case .tooLongOtherInterests:
                                    return Alert(title: Text("Too Long Other Interests"), message: Text("Your other interests must be no longer than 100 characters."), dismissButton: .default(Text("OK")))
                                }
                        }
                    }
                }
            }
            .navigationBarTitle("Interests")
            .onAppear {
                // Reset birthday here instead of on appear of Set Profile View since it may be navigated from views within itself.
                var dateComponents: DateComponents? = Calendar.current.dateComponents([.hour, .minute, .second], from: self.global.getUtcTime())
                dateComponents?.year = 2000
                dateComponents?.month = 1
                dateComponents?.day = 1
                self.global.birthday = Calendar.current.date(from: dateComponents!)!
                
                self.isSelectedList = [Bool](repeating: false, count: self.global.interestsOptions.count)
                self.isReady = true
            }
            .modifier(AdaptsToKeyboard())
        }
        .navigationViewStyle(StackNavigationViewStyle()) // needed so screen works on iPad
    }
}

struct SelectInterestsView_Previews: PreviewProvider {
    static var previews: some View {
        SelectInterestsView()
            .environmentObject(Global())
    }
}
