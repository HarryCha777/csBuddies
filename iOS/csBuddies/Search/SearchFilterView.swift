//
//  SearchFilterView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/19/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase

struct SearchFilterView: View {
    @EnvironmentObject var global: Global
    @Environment(\.presentationMode) var presentation
    
    private struct AlertId: Identifiable {
        enum Id {
            case
            tooManyFilters
        }
        var id: Id
    }

    @State private var isReady = false
    @State private var filterGenderOptions = [String]()
    @State private var filterCountryOptions = [String]()
    @State private var filterLevelOptions = [String]()
    @State private var filterSortOptions = ["Last Visit", "Last Update", "New Users"]
    @State private var alertId: AlertId?
    
    var body: some View {
        Form {
            if isReady {
                Section(header: Text("Demographics")) {
                    Picker("", selection: $global.newFilterGenderIndex) {
                        ForEach(filterGenderOptions.indices) { index in
                            Text(self.filterGenderOptions[index])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer()
                            .frame(height: 7)
                        Text("Age range: \(toAge(double: global.newFilterAgeRange.lowerBound)) - \(toAge(double: global.newFilterAgeRange.upperBound))")
                        RangeSlider(range: $global.newFilterAgeRange)
                            .rangeSliderStyle(
                                HorizontalRangeSliderStyle(
                                    lowerThumbSize: CGSize(width: 20, height: 20),
                                    upperThumbSize: CGSize(width: 20, height: 20)
                                )
                            )
                    }
                    
                    Picker("Must live in", selection: $global.newFilterCountryIndex) {
                        ForEach(filterCountryOptions.indices) { index in
                            Text(self.filterCountryOptions[index])
                        }
                    }
                }
                
                Section(header: Text("Interests")) {
                    NavigationLink(destination: SearchFilterInterestsView()) {
                        Text("Must be interested in")
                    }
                    
                    Picker("", selection: $global.newFilterLevelIndex) {
                        ForEach(filterLevelOptions.indices) { index in
                            Text(self.filterLevelOptions[index])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Optional")) {
                    Toggle(isOn: $global.newFilterHasImage) {
                        Text("Must have Image")
                    }
                    
                    Toggle(isOn: $global.newFilterHasGitHub) {
                        Text("Must have GitHub")
                    }
                    
                    Toggle(isOn: $global.newFilterHasLinkedIn) {
                        Text("Must have LinkedIn")
                    }
                }
                
                Section(header: Text("Sort")) {
                    Picker("", selection: $global.newFilterSortIndex) {
                        ForEach(filterSortOptions.indices) { index in
                            Text(self.filterSortOptions[index])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Button(action: {
                    self.global.newFilterGenderIndex = 0
                    self.global.newFilterMinAge = 13
                    self.global.newFilterMaxAge = 80
                    self.global.newFilterAgeRange = 0.0...1.0
                    self.global.newFilterCountryIndex = 0
                    self.global.newFilterHasImage = false
                    self.global.newFilterHasGitHub = false
                    self.global.newFilterHasLinkedIn = false
                    self.global.newFilterInterests = ""
                    self.global.newFilterLevelIndex = 0
                    self.global.newFilterSortIndex = 0
                }) {
                    Text("Reset")
                }
                
                Button(action: {
                    if self.global.isPremium || self.getFilterCounter() <= 2 {
                        self.applyFilters()
                    } else {
                        self.alertId = AlertId(id: .tooManyFilters)
                    }
                    
                }) {
                    HStack {
                        Text("Apply Filters")
                            .alert(item: $alertId) { alert in
                                switch alert.id {
                                case .tooManyFilters:
                                    return Alert(title: Text("Three or More Filters"), message: Text("To apply 3 or more filters at once, you need to watch one ad."), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("OK"), action: {
                                        if self.global.admobRewardedAdsFilter.rewardedAd.isReady {
                                            self.global.admobRewardedAdsFilter.showAd(rewardFunction: {
                                                self.applyFilters()
                                            })
                                        } else {
                                            self.applyFilters()
                                        }
                                    }))
                                }
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Filter Search", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: global.cancelButton(presentation: presentation))
        .onAppear {
            self.filterGenderOptions.append("All")
            self.filterGenderOptions.append(contentsOf: self.global.genderOptions)
            
            self.filterCountryOptions.append("Anywhere")
            self.filterCountryOptions.append(contentsOf: self.global.countryOptions)
            
            self.filterLevelOptions.append("Both")
            self.filterLevelOptions.append(contentsOf: self.global.levelOptions)
            
            self.isReady = true
        }
    }
    
    func toAge(double: Double) -> Int {
        return Int(double * Double(80 - 13)) + 13
    }
    
    func getFilterCounter() -> Int {
        var filterCounter = 0
        
        if global.newFilterGenderIndex != 0 {
            filterCounter += 1
        }
        if global.newFilterAgeRange != 0.0...1.0 {
            filterCounter += 1
        }
        if global.newFilterCountryIndex != 0 {
            filterCounter += 1
        }
        if global.newFilterInterests != "" {
            filterCounter += 1
        }
        if global.newFilterLevelIndex != 0 {
            filterCounter += 1
        }
        if global.newFilterHasImage {
            filterCounter += 1
        }
        if global.newFilterHasGitHub {
            filterCounter += 1
        }
        if global.newFilterHasLinkedIn {
            filterCounter += 1
        }
        if global.newFilterSortIndex != 0 {
            filterCounter += 1
        }
        
        return filterCounter
    }
    
    func applyFilters() {
        global.filterGenderIndex = global.newFilterGenderIndex
        global.filterMinAge = toAge(double: global.newFilterAgeRange.lowerBound)
        global.filterMaxAge = toAge(double: global.newFilterAgeRange.upperBound)
        global.filterCountryIndex = global.newFilterCountryIndex
        global.filterInterests = global.newFilterInterests
        global.filterLevelIndex = global.newFilterLevelIndex
        global.filterHasImage = global.newFilterHasImage
        global.filterHasGitHub = global.newFilterHasGitHub
        global.filterHasLinkedIn = global.newFilterHasLinkedIn
        global.filterSortIndex = global.newFilterSortIndex
        
        Analytics.logEvent("search_filter", parameters: [
            "gender": filterGenderOptions[global.filterGenderIndex],
            "min_age": String(global.filterMinAge),
            "max_age": String(global.filterMaxAge),
            "country": filterCountryOptions[global.filterCountryIndex],
            "interests": global.filterInterests,
            "level": filterLevelOptions[global.filterLevelIndex],
            "hasImage": String(global.filterHasImage),
            "hasGitHub": String(global.filterHasGitHub),
            "hasLinkedIn": String(global.filterHasLinkedIn),
            "sort": filterSortOptions[global.filterSortIndex],
        ])
        
        global.mustSearch = true
        presentation.wrappedValue.dismiss()
    }
}
