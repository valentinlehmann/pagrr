//
//  AccountPopoverViewModel.swift
//  Pagrr
//
//  Created by Valentin Lehmann on 01.01.26.
//

import SwiftUI
import FirebaseAuth

@Observable
class AccountPopoverViewModel {
    private var handle: AuthStateDidChangeListenerHandle?
    var currentUser = Auth.auth().currentUser
    
    func viewWillAppear() {
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            self.currentUser = user
        }
    }

    func viewWillDisappear() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
