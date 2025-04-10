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
    
    @State private var filterSortOptions = ["Hot", "New"]
    
    @State private var newBytesFilterSort = globalObject.bytesFilterSort

    var body: some View {
        List {
            Section(header: Text("Sort")) {
                Picker("", selection: $newBytesFilterSort) {
                    ForEach(filterSortOptions.indices) { index in
                        Text(filterSortOptions[index])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Filter Bytes", displayMode: .inline)
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
        global.bytesFilterSort = newBytesFilterSort
        
        mustGetBytes = true
        presentation.wrappedValue.dismiss()
    }
}
