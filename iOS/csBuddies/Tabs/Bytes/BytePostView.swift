//
//  BytePostView.swift
//  csBuddies
//
//  Created by Harry Cha on 1/11/21.
//  Copyright © 2021 Harry Cha. All rights reserved.
//

import SwiftUI

struct BytePostView: View {
    @EnvironmentObject var global: Global
    
    let byteId: String
    // global.bytes[byteId] must be set in advance.
    
    var body: some View {
        if !global.bytes[byteId]!.isDeleted {
            VStack(alignment: .leading) {
                NavigationLinkBorderless(destination: UserView(userId: global.bytes[byteId]!.userId)) {
                    HStack(alignment: .top) {
                        SmallImageView(userId: global.bytes[byteId]!.userId, isOnline: global.isOnline(lastVisitedAt: global.bytes[byteId]!.lastVisitedAt), size: 35)
                        
                        Spacer()
                            .frame(width: 10)
                        
                        VStack(alignment: .leading) {
                            Text(global.bytes[byteId]!.username)
                                .bold()
                                .lineLimit(1)
                            Text(global.bytes[byteId]!.postedAt.toTimeDifference())
                                .foregroundColor(.gray)
                                .font(.footnote)
                        }
                        
                        Spacer()
                    }
                }
                
                Text(global.bytes[byteId]!.content)
                    .fixedSize(horizontal: false, vertical: true)
            
                Spacer()
                    .frame(height: 20)
                
                HStack {
                    ByteHeartView(byteId: byteId)
                    Text("\(global.bytes[byteId]!.likes)")
                    
                    Spacer()
                    
                    NavigationLinkBorderless(destination: ByteLikesView(byteId: byteId)) {
                        Image(systemName: "person.3.fill")
                            .foregroundColor(.gray)
                        Text("Likes")
                    }
                    
                    Spacer()
                    
                    Image(systemName: "bubble.left.fill")
                        .foregroundColor(.gray)
                    Text("\(global.bytes[byteId]!.comments)")
                    
                    // Unlike comment reply buttons, do not have a button to directly comment on the Byte except in ByteView
                    // because the user must view the full context, including the Byte's comments, before commenting.
                }
            }
            .padding(.vertical)
        }
    }
}
