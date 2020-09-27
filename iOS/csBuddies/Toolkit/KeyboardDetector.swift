//
//  KeyboardDetector.swift
//  Code Buddies Finder
//
//  Created by Harry Cha on 6/11/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

class KeyboardDetector: ObservableObject {
    private var notificationCenter: NotificationCenter
    
    @Published var isKeyboardShown = false
    
    init(center: NotificationCenter = .default) {
        notificationCenter = center
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    @objc func keyBoardWillShow(notification: Notification) {
        isKeyboardShown = true
    }
    
    @objc func keyBoardWillHide(notification: Notification) {
        isKeyboardShown = false
    }
}
