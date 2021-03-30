//
//  BuddiesFilterView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/19/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase

struct BuddiesFilterView: View {
    @EnvironmentObject var global: Global
    @Environment(\.presentationMode) var presentation
    
    @Binding var mustGetBuddies: Bool
    
    @State private var filterGenderOptions = ["All"] + globalObject.genderOptions
    @State private var filterCountryOptions = ["Worldwide"] + globalObject.countryOptions
    @State private var filterSortOptions = ["Active", "New"]
    
    @State private var newBuddiesFilterGender = globalObject.buddiesFilterGender
    @State private var newBuddiesFilterMinAge = globalObject.buddiesFilterMinAge
    @State private var newBuddiesFilterMaxAge = globalObject.buddiesFilterMaxAge
    @State private var newBuddiesFilterCountry = globalObject.buddiesFilterCountry
    @State private var newBuddiesFilterInterests = globalObject.buddiesFilterInterests
    @State private var newBuddiesFilterSort = globalObject.buddiesFilterSort
    
    var body: some View {
        List {
            Section(header: Text("Demographics")) {
                Picker("", selection: $newBuddiesFilterGender) {
                    ForEach(filterGenderOptions.indices) { index in
                        if index != filterGenderOptions.count - 1 {
                            Text(filterGenderOptions[index])
                        }
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                NavigationLink(destination:
                                BuddiesFilterAgeView(newBuddiesFilterMinAge: $newBuddiesFilterMinAge, newBuddiesFilterMaxAge: $newBuddiesFilterMaxAge)
                                .environmentObject(globalObject)
                ) {
                    HStack {
                        Text("Age")
                        Spacer()
                        Text("\(newBuddiesFilterMinAge) - \(newBuddiesFilterMaxAge)")
                            .foregroundColor(.gray)
                    }
                }
                
                Picker("Country", selection: $newBuddiesFilterCountry) {
                    ForEach(filterCountryOptions.indices) { index in
                        Text(filterCountryOptions[index])
                    }
                }
            }
            
            Section(header: Text("Interests")) {
                NavigationLink(
                    destination:
                        List {
                            InterestsView(interests: $newBuddiesFilterInterests)
                                .environmentObject(globalObject)
                        }
                        .listStyle(PlainListStyle())
                        .navigationBarTitle("Filter Interests", displayMode: .inline)
                ) {
                    VStack(alignment: .leading) {
                        if newBuddiesFilterInterests.count == 0 {
                            Text("Interests")
                        } else {
                            TagsView(data: newBuddiesFilterInterests) { interest in
                                InterestsButtonDisabledView(interest: interest, interests: newBuddiesFilterInterests)
                            }
                        }
                    }
                }
            }
            
            Section(header: Text("Sort")) {
                Picker("", selection: $newBuddiesFilterSort) {
                    ForEach(filterSortOptions.indices) { index in
                        Text(filterSortOptions[index])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Filter Buddies", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                BackButton(title: "Cancel", presentation: presentation)
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    applyFilters()
                }) {
                    Text("Apply")
                }
            }
        }
    }
    
    func applyFilters() {
        global.buddiesFilterGender = newBuddiesFilterGender
        global.buddiesFilterMinAge = newBuddiesFilterMinAge
        global.buddiesFilterMaxAge = newBuddiesFilterMaxAge
        global.buddiesFilterCountry = newBuddiesFilterCountry
        global.buddiesFilterInterests = newBuddiesFilterInterests
        global.buddiesFilterSort = newBuddiesFilterSort
        
        mustGetBuddies = true
        presentation.wrappedValue.dismiss()
    }
}
