//
//  ContentView.swift
//  Pagrr
//
//  Created by Valentin Lehmann on 01.01.26.
//

import SwiftUI
import FirebaseAuth
import FirebaseMessaging

struct MainView: View {
    @State private var viewModel = MainViewModel()
    
    var body: some View {
        Group {
            if viewModel.isUserLoggedIn {
                ChannelListView()
            } else {
                LoginView()
            }
        }
        .onAppear {
            viewModel.viewWillAppear()
        }
        .onDisappear {
            viewModel.viewWillDisappear()
        }
    }
}

#Preview {
    MainView()
}
