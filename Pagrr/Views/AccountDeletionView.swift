//
//  AccountDeletionView.swift
//  Pagrr
//
//  Created by Valentin Lehmann on 02.01.26.
//

import SwiftUI

struct AccountDeletionView: View {
    @State private var viewModel = AccountDeletionViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section("Channels") {
                        if !viewModel.channelsFetched {
                            ProgressView()
                        } else {
                            ForEach(viewModel.channels) { channel in
                                if channel.owners.count == 1 {
                                    HStack {
                                        Text(channel.name)
                                        Spacer()
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.accentColor)
                                    }
                                } else {
                                    Text(channel.name)
                                }
                            }
                            if viewModel.channels.isEmpty {
                                Text("You have no channels.", comment: "Indicates that there are no channels in the Account Deletion View")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                Text("Channels marked with an exclamatin mark (!) will be deleted permanently, as you are the only owner.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    
                Spacer()
                Button {
                    viewModel.startSignInWithAppleFlow()
                } label: {
                    Image(systemName: "trash")
                    Text("Reauthenticate and Delete My Account")
                }
                .controlSize(.large)
                .buttonStyle(.glassProminent)
                .padding()
                Button {
                    dismiss()
                } label: {
                    Text("I changed my mind")
                }
            }
            .padding()
            .navigationTitle("Delete Account")
            .navigationSubtitle("Are you sure you want to delete your account?")
            .navigationBarTitleDisplayMode(.inline)
            .presentationDragIndicator(.visible)
            .presentationDetents([.large])
            .onAppear {
                viewModel.fetchChannels()
            }
        }
    }
}

#Preview {
    @Previewable @State var isPresented = true
    
    VStack {
        Button("Show Account Deletion View") {
            isPresented = true
        }
    }
    .sheet(isPresented: $isPresented) {
        AccountDeletionView()
    }
}
