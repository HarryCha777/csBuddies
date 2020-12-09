//
//  ConfirmationView.swift
//  csBuddies
//
//  Created by Harry Cha on 12/6/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct ConfirmationView: View {
    @EnvironmentObject var global: Global
    
    var body: some View {
        if global.confirmationText != "" {
            Spacer()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        global.confirmationText = ""
                    })
                }
        }
        
        VStack {
            Image(systemName: "checkmark")
                .foregroundColor(.white)
                .font(.system(size: 100))
            Spacer()
                .frame(height: 30)
            Text(global.confirmationText)
                .foregroundColor(.white)
                .font(.largeTitle)
        }
        .frame(width: 200, height: 200)
        .background(Color.black.opacity(0.5))
        .cornerRadius(15)
        .opacity(global.confirmationText != "" ? 1 : 0)
        .animation(.easeInOut(duration: 0.5))
    }
}
