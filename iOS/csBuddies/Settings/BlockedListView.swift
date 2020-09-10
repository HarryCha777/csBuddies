//
//  BlockedListView.swift
//  csBuddies
//
//  Created by Harry Cha on 6/12/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct BlockedListView: View {
    @EnvironmentObject var global: Global
    
    var body: some View {
        List {
            ForEach(global.blockedList, id: \.self) { blockedUsername in
                Text("\(blockedUsername)")
            }
            .onDelete(perform: deleteBlocked)
            
            if global.blockedList.count == 0 {
                Text("You have not blocked anyone.")
            }
        }
        .navigationBarTitle("Blocked List", displayMode: .inline)
        .navigationBarItems(trailing: EditButton())
    }
    
    func deleteBlocked(at offsets: IndexSet) {
        global.unblock(buddyUsername: global.blockedList[offsets.first!])
    }
}

struct BlockedListView_Previews: PreviewProvider {
    static var previews: some View {
        BlockedListView()
    }
}
