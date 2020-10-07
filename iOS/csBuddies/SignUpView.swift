//
//  SignUpView.swift
//  csBuddies
//
//  Created by Harry Cha on 10/2/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var global: Global
    
    var body: some View {
        switch global.signUpId.id {
        case .selectInterests:
            SelectInterestsView()
        case .setProfile:
            SetProfileView()
        case .typeIntro:
            TypeIntroView()
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
