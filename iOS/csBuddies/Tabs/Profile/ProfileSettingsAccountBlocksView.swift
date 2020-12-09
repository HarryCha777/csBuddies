//
//  ProfileSettingsAccountBlocksView.swift
//  csBuddies
//
//  Created by Harry Cha on 6/12/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct ProfileSettingsAccountBlocksView: View {
    @EnvironmentObject var global: Global
    
    var body: some View {
        List {
            ForEach(global.blocks.reversed()) { userRowData in
                NavigationLinkBorderless(destination: BuddiesProfileView(buddyId: userRowData.userId))  {
                    UserRowView(userRowData: userRowData)
                }
            }
            .onDelete(perform: deleteBlocked)
            .id(UUID())

            if global.blocks.count == 0 {
                Text("You have not blocked anyone.")
            }
        }
        .navigationBarTitle("Blocked Users", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                EditButton()
            }
        }
    }
    
    func deleteBlocked(at offsets: IndexSet) {
        let index = global.blocks.count - 1 - offsets.first! // Reverse index since array is reversed.
        global.unblock(buddyId: global.blocks[index].userId)
    }
}
