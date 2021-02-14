//
//  SetInterestsView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/16/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct SetInterestsView: View {
    @EnvironmentObject var global: Global
    
    @State private var mustVisitSetProfile = false

    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            tooLongOtherInterests
    }
    
    var body: some View {
        ZStack {
            List {
                JoinStepperView(step: 1)
                InterestsView(interests: $global.interests)
                    .environmentObject(globalObject)
                Section(header: Text("Others")) {
                    TextField("Ex: Design, Desktop, Graphics, etc", text: $global.otherInterests)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            .listStyle(PlainListStyle())
            // Do not use .removeHeaderPadding() because of .listStyle(PlainListStyle()).
            
            NavigationLinkEmpty(destination: SetUserProfileView(), isActive: $mustVisitSetProfile)
        }
        .navigationBarTitle("Interests", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    if global.otherInterests.count > 100 {
                        activeAlert = .tooLongOtherInterests
                    } else {
                        mustVisitSetProfile = true
                    }
                }) {
                    Text("Next")
                }
            }
        }
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .tooLongOtherInterests:
                return Alert(title: Text("Too Long Other Interests"), message: Text("Your other interests must be no longer than 100 characters."), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct SetInterestsView_Previews: PreviewProvider {
    static var previews: some View {
        SetInterestsView()
            .environmentObject(globalObject)
    }
}
