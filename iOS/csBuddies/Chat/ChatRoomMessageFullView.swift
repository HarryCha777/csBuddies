//
//  ChatRoomMessageFullView.swift
//  csBuddies
//
//  Created by Harry Cha on 8/5/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct ChatRoomMessageFullView: View {
    let messageContent: String
    
    var body: some View {
        ScrollView {
            Text("\(messageContent)")
                .padding()
        }
    }
}
