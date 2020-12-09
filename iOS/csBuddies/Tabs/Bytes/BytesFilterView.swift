//
//  BytesFilterView.swift
//  csBuddies
//
//  Created by Harry Cha on 10/21/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase

struct BytesFilterView: View {
    @EnvironmentObject var global: Global
    @Environment(\.presentationMode) var presentation
    
    @Binding var mustGetBytes: Bool
    
    @State private var filterSortOptions = ["New", "Trending", "Likes"]
    @State private var filterTimeOptions = ["Week", "Month", "All Time"] // Omit "Day" because trending essentially takes of it.

    var body: some View {
        List {
            Section(header: Text("Sort")) {
                Picker("", selection: $global.newBytesFilterSortIndex) {
                    ForEach(filterSortOptions.indices) { index in
                        Text(filterSortOptions[index])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            if global.newBytesFilterSortIndex == 2 {
                Section(header: Text("Time")) {
                    Picker("", selection: $global.newBytesFilterTimeIndex) {
                        ForEach(filterTimeOptions.indices) { index in
                            Text(filterTimeOptions[index])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Filter Bytes", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                global.backButton(presentation: presentation, title: "Cancel")
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
        global.bytesFilterSortIndex = global.newBytesFilterSortIndex
        global.bytesFilterTimeIndex = global.newBytesFilterTimeIndex

        Analytics.logEvent("bytes_filter", parameters: [
            "sort": filterSortOptions[global.bytesFilterSortIndex],
            "time": filterTimeOptions[global.bytesFilterTimeIndex],
        ])
        
        mustGetBytes = true
        presentation.wrappedValue.dismiss()
    }
}
