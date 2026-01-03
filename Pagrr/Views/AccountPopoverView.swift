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
                Button {
                    do {
                        try AuthService.shared.signOut()
                    } catch {
                        print("Error signing out: \(error.localizedDescription)")
                    }
                } label: {
                    Text("Sign Out")
                        .padding(.horizontal, 70)
                }
                .buttonStyle(.glass)
                .controlSize(.large)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                Button("Delete Account") {
                    showDeleteAccountConfirmation = true
                }
                .sheet(isPresented: $showDeleteAccountConfirmation) {
                    AccountDeletionView()
                }
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
