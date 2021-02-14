//
//  InterestsView.swift
//  csBuddies
//
//  Created by Harry Cha on 11/10/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct InterestsView: View {
    @EnvironmentObject var global: Global

    @Binding var interests: [String]

    var body: some View {
        Section(header: Text("Languages")) {
            TagsView(data: global.interestOptions[0 ..< 23]) { interest in
                InterestsButtonEnabledView(interest: interest, interests: $interests)
                    .environmentObject(globalObject)
            }
        }
        
        Section(header: Text("Tools")) {
            TagsView(data: global.interestOptions[23 ..< 23 + 16]) { interest in
                InterestsButtonEnabledView(interest: interest, interests: $interests)
                    .environmentObject(globalObject)
            }
        }
        
        Section(header: Text("Subjects")) {
            TagsView(data: global.interestOptions[23 + 16 ..< global.interestOptions.count]) { interest in
                InterestsButtonEnabledView(interest: interest, interests: $interests)
                    .environmentObject(globalObject)
            }
        }
    }
}
