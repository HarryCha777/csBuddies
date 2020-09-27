//
//  SearchFilterInterestsView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/19/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct SearchFilterInterestsView: View {
    @EnvironmentObject var global: Global
    
    @State private var isSelectedList = [Bool]()
    @State private var isReady = false
    
    var body: some View {
        Form {
            if isReady {
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
            }
        }
        .navigationBarTitle("Filter Interests", displayMode: .inline)
        .onAppear {
            self.isSelectedList = self.global.newFilterInterests.toIsSelectedList()
            self.isReady = true
        }
        .onDisappear {
            self.global.newFilterInterests = self.isSelectedList.toInterests()
        }
    }
}

struct SearchFilterInterestsView_Preview: PreviewProvider {
    static var previews: some View {
        SearchFilterInterestsView()
            .environmentObject(Global())
    }
}
