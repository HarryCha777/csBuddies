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
    
    var body: some View {
        List {
            Section(header: Text("Demographics")) {
                Picker("", selection: $global.newBuddiesFilterGenderIndex) {
                    ForEach(filterGenderOptions.indices) { index in
                        if index != filterGenderOptions.count - 1 {
                            Text(filterGenderOptions[index])
                        }
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                NavigationLink(destination:
                                BuddiesFilterAgeView()
                                .environmentObject(globalObject)
                ) {
                    HStack {
                        Text("Age")
                        Spacer()
                        Text("\(global.newBuddiesFilterMinAge) - \(global.newBuddiesFilterMaxAge)")
                            .foregroundColor(.gray)
                    }
                }
                
                Picker("Country", selection: $global.newBuddiesFilterCountryIndex) {
                    ForEach(filterCountryOptions.indices) { index in
                        Text(filterCountryOptions[index])
                    }
                }
            }
            
            Section(header: Text("Interests")) {
                NavigationLink(
                    destination:
                        List {
                            InterestsView(interests: $global.newBuddiesFilterInterests)
                                .environmentObject(globalObject)
                        }
                        .listStyle(PlainListStyle())
                        .navigationBarTitle("Filter Interests", displayMode: .inline)
                ) {
                    VStack(alignment: .leading) {
                        if global.newBuddiesFilterInterests.count == 0 {
                            Text("Interests")
                        } else {
                            TagsView(data: global.newBuddiesFilterInterests) { interest in
                                InterestsButtonDisabledView(interest: interest, interests: global.newBuddiesFilterInterests)
                            }
                        }
                    }
                }
            }
            
            Section(header: Text("Sort")) {
                Picker("", selection: $global.newBuddiesFilterSortIndex) {
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
        global.buddiesFilterGenderIndex = global.newBuddiesFilterGenderIndex
        global.buddiesFilterMinAge = global.newBuddiesFilterMinAge
        global.buddiesFilterMaxAge = global.newBuddiesFilterMaxAge
        global.buddiesFilterCountryIndex = global.newBuddiesFilterCountryIndex
        global.buddiesFilterInterests = global.newBuddiesFilterInterests
        global.buddiesFilterSortIndex = global.newBuddiesFilterSortIndex

        Analytics.logEvent("buddies_filter", parameters: [
            "gender": filterGenderOptions[global.buddiesFilterGenderIndex],
            "min_age": String(global.buddiesFilterMinAge),
            "max_age": String(global.buddiesFilterMaxAge),
            "country": filterCountryOptions[global.buddiesFilterCountryIndex],
            "interests": global.buddiesFilterInterests.toInterestsString(),
            "sort": filterSortOptions[global.buddiesFilterSortIndex],
        ])
        
        mustGetBuddies = true
        presentation.wrappedValue.dismiss()
    }
}
