//
//  ProfileSettingsAccountSavedUsersView.swift
//  csBuddies
//
//  Created by Harry Cha on 6/12/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct ProfileSettingsAccountSavedUsersView: View {
    @EnvironmentObject var global: Global
    
    var body: some View {
        List {
            ForEach(global.savedUsers.reversed()) { userRowData in
                NavigationLinkBorderless(destination: BuddiesProfileView(buddyId: userRowData.userId))  {
                    UserRowView(userRowData: userRowData)
                }
            }
            .onDelete(perform: deleteSavedUser)
            .id(UUID())

            if global.savedUsers.count == 0 {
                Text("You have not saved anyone.")
            }
        }
        .navigationBarTitle("Saved Users", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                EditButton()
            }
        }
    }
    
    func deleteSavedUser(at offsets: IndexSet) {
        let index = global.savedUsers.count - 1 - offsets.first! // Reverse index since array is reversed.
        global.forgetUser(buddyId: global.savedUsers[index].userId)
    }
}
