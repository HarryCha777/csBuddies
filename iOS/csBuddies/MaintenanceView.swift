//
//  MaintenanceView.swift
//  csBuddies
//
//  Created by Harry Cha on 10/1/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct MaintenanceView: View {
    var body: some View {
        VStack {
            Text("Under Maintenance")
                .font(.largeTitle)
                .padding()
            
            Text("The app is currently undergoing maintenance.\n\n" +
                    "We will be back shortly.\n" +
                    "Thank you for your patience.")
        }
    }
}
