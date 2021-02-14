//
//  BackButton.swift
//  csBuddies
//
//  Created by Harry Cha on 2/5/21.
//  Copyright © 2021 Harry Cha. All rights reserved.
//

import SwiftUI

struct BackButton: View {
    let title: String
    var presentation: Binding<PresentationMode>
    
    var body: some View {
        Button(action: {
            presentation.wrappedValue.dismiss()
        }) {
            Text(title)
        }
    }
}
