//
//  ChannelInfoView.swift
//  Pagrr
//
//  Created by Valentin Lehmann on 02.01.26.
//

import SwiftUI
import FirebaseAuth

struct ChannelInfoView: View {
    @State private var viewModel: ChannelInfoViewModel
    @FocusState private var isNameFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss
    private var onChannelDeleted: (() -> Void)?
    
    init(channel: Channel, onChannelDeleted: (() -> Void)? = nil) {
        self.viewModel = ChannelInfoViewModel(channelId: channel.id)
        self.onChannelDeleted = onChannelDeleted
    }
    
    var body: some View {
        List {
            Section("About the channel") {
                VStack(alignment: .leading) {
                    Text("Name", comment: "Label for the channel name")
                        .font(.caption)
                        .foregroundColor(.gray)
                    if viewModel.nameEditMode {
                        TextField("Name",
                                  text: $viewModel.editedName,
                                  onCommit: {
                            viewModel.updateChannelName()
                        })
                        .submitLabel(.done)
                        .focused($isNameFieldFocused)
                    } else {
                        Text(viewModel.channel.name)
                            .font(.body)
                            .contextMenu {
                                Button {
                                    viewModel.nameEditMode = true
                                } label: {
                                    Label("Edit Name", systemImage: "pencil")
                                }
                            }
                    }
                }
                VStack(alignment: .leading) {
                    Text("ID", comment: "Label for the channel ID")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(viewModel.channel.id)
                        .font(.body)
                        .contextMenu {
                            Button {
                                UIPasteboard.general.string = viewModel.channel.id
                            } label: {
                                Label("Copy ID", systemImage: "doc.on.doc")
                            }
                        }
                }
                VStack(alignment: .leading) {
                    Text("Created At", comment: "Label for the channel creation date")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(viewModel.channel.createdAt.formatted())
                        .font(.body)
                }
                VStack(alignment: .leading) {
                    Text("API Key", comment: "Label for the channel API key")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(viewModel.channel.apiKey)
                        .font(.body)
                        .contextMenu {
                            HStack {
                                Button {
                                    UIPasteboard.general.string = viewModel.channel.apiKey
                                } label: {
                                    Label("Copy API Key", systemImage: "doc.on.doc")
                                }
                                if viewModel.showApiKey {
                                    Button {
                                        viewModel.showApiKey = false
                                    } label: {
                                        Label("Hide API Key", systemImage: "eye.slash" )
                                    }
                                } else {
                                    Button {
                                        viewModel.showApiKey = true
                                    } label: {
                                        Label("Show API Key", systemImage: "eye")
                                    }
                                }
                                Button(role: .destructive) {
                                    viewModel.resetApiKey()
                                }
                                label: {
                                    Label("Reset API Key", systemImage: "arrow.clockwise")
                                }
                            }
                        }
                        .blur(radius: viewModel.showApiKey ? 0 : 7)
                }
            }
            Section("Owners") {
                ForEach(viewModel.channel.owners, id: \.self) { owner in
                    if owner == Auth.auth().currentUser?.uid {
                        Text("\(owner) (You)")
                            .font(.body)
                    } else {
                        Text(owner)
                            .font(.body)
                            .swipeActions {
                                Button(role: .destructive) {
                                    Task {
                                        viewModel.removeOwner(owner)
                                    }
                                } label: {
                                    Label("Remove", systemImage: "minus.circle")
                                }
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    Task {
                                        viewModel.removeOwner(owner)
                                    }
                                } label: {
                                    Label("Remove", systemImage: "minus.circle")
                                }
                            }
                    }
                }
                Button {
                    Task {
                        if let newOwnerId = await viewModel.promptForNewOwnerId() {
                            viewModel.addOwner(newOwnerId)
                        }
                    }
                } label: {
                    Label("Add Owner", systemImage: "plus.circle")
                }
            }
            Section("Manage channel") {
                Button {
                    viewModel.copyConfiguration()
                } label: {
                    Label("Copy cURL Command", systemImage: "apple.terminal")
                }
                Button(role: .destructive) {
                    Task {
                        viewModel.deleteChannel()
                        onChannelDeleted?()
                        dismiss()
                    }
                    
                    print("Button pressed")
                } label: {
                    Label("Delete Channel", systemImage: "trash").foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Info")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.nameEditMode) { oldValue, newValue in
            isNameFieldFocused = newValue
        }
        .onDisappear {
            viewModel.showApiKey = false
        }
    }
}

#Preview {
    ChannelInfoView(channel: Channel(id: "1", name: "General", createdAt: Date(), owners: ["user1"], apiKey: "123"))
}
