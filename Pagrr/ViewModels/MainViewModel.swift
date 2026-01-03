//
//  MainViewModel.swift
//  Pagrr
//
//  Created by Valentin Lehmann on 01.01.26.
//

import FirebaseAuth
import SwiftUI

@Observable
class MainViewModel {
    private var handle: AuthStateDidChangeListenerHandle?
    var isUserLoggedIn = Auth.auth().currentUser != nil
    
    func viewWillAppear() {
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            self.isUserLoggedIn = (user != nil)
        }
    }

    func viewWillDisappear() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
