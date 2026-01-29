//
//  AccountPopoverView.swift
//  Pagrr
//
//  Created by Valentin Lehmann on 01.01.26.
//

import SwiftUI
import FirebaseAuth

struct AccountPopoverView: View {
    @State private var viewModel = AccountPopoverViewModel()
    @State private var showDeleteAccountConfirmation = false
    @FocusState private var isNameFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let user = viewModel.currentUser {
                Text(user.email ?? "Anonymous User")
                    .bold()
                Divider()
                Button() {
                    if let url = URL(string: "https://legal.valentinlehmann.de") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Image(systemName: "person.circle")
                    Text("Imprint")
                }
                Button() {
                    if let url = URL(string: "https://legal.valentinlehmann.de/privacy") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Image(systemName: "lock.circle")
                    Text("Privacy Policy")
                }
                Divider()
                Button() {
                    showDeleteAccountConfirmation = true
                } label: {
                    Image(systemName: "trash.circle")
                    Text("Delete Account")
                }
                .foregroundStyle(.red)
                .sheet(isPresented: $showDeleteAccountConfirmation) {
                    AccountDeletionView()
                }
                Button() {
                    do {
                        try AuthService.shared.signOut()
                    } catch {
                        print("Error signing out: \(error.localizedDescription)")
                    }
                } label: {
                    Image(systemName: "arrow.right.circle")
                    Text("Sign Out")
                }
                .foregroundStyle(.red)
            } else {
                Text("No user logged in")
            }
        }
        .onAppear {
            viewModel.viewWillAppear()
        }
        .onDisappear {
            viewModel.viewWillDisappear()
        }
        .padding()
        .presentationCompactAdaptation(.popover)
    }
}

#Preview {
    AccountPopoverView()
}
