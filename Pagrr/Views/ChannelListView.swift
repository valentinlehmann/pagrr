//
//  ChannelListView.swift
//  Pagrr
//
//  Created by Valentin Lehmann on 01.01.26.
//

import SwiftUI
import FirebaseAuth

struct ChannelListView: View {
    @State private var viewModel = ChannelListViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                Section("Channels") {
                    ForEach(viewModel.channels) { channel in
                        NavigationLink (destination: ChannelDetailView(channel: channel)) {
                            Text(channel.name)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                viewModel.deleteChannel(id: channel.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                viewModel.deleteChannel(id: channel.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    if viewModel.isLoading {
                        VStack(alignment: .center, spacing: 8) {
                            ProgressView()
                            Text("Loading channels...")
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                    } else if viewModel.channels.isEmpty {
                        Text("No channels available. \nCreate one by tapping the button in the bottom right corner.", comment: "Indicates that there are no channels")
                            .foregroundColor(.gray)
                    }
                }
            }
            .onAppear {
                viewModel.fetchChannels()
            }
            .refreshable {
                viewModel.fetchChannels()
            }
            .navigationTitle("Pagrr")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.isShowingAccountPopover.toggle()
                    } label: {
                        Image(systemName: "person")
                    }
                    .popover(isPresented: $viewModel.isShowingAccountPopover) {
                        AccountPopoverView()
                    }
                }
                ToolbarSpacer(placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        Task {
                            viewModel.createChannel()
                        }
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.glassProminent)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChannelListView()
    }
}
