//
//  ProfileSettingsAccountSavedBytesView.swift
//  csBuddies
//
//  Created by Harry Cha on 11/28/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct ProfileSettingsAccountSavedBytesView: View {
    @EnvironmentObject var global: Global
    
    var body: some View {
        List {
            ForEach(global.savedBytes.reversed()) { bytesPostData in
                BytesPostView(bytesPostData: bytesPostData)
            }
            .onDelete(perform: deleteSavedByte)
            .id(UUID())

            if global.savedBytes.count == 0 {
                Text("You have not saved any byte.")
            }
        }
        .navigationBarTitle("Saved Bytes", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                EditButton()
            }
        }
    }
    
    func deleteSavedByte(at offsets: IndexSet) {
        let index = global.savedBytes.count - 1 - offsets.first! // Reverse index since array is reversed.
        global.forgetByte(byteId: global.savedBytes[index].byteId)
    }
}
