//
//  ChannelDetailView.swift
//  Pagrr
//
//  Created by Valentin Lehmann on 01.01.26.
//

import SwiftUI
import FirebaseAuth

struct ChannelDetailView: View {
    @State var viewModel: ChannelDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(channel: Channel) {
        self.viewModel = ChannelDetailViewModel(channel: channel)
    }
    
    var body: some View {
        Group {
            List {
                Section("Messages") {
                    ForEach(viewModel.messages) { message in
                        VStack(alignment: .leading) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading) {
                                    Text(.init(message.title))
                                        .font(.headline)
                                    Text(.init(message.description))
                                        .font(.subheadline)
                                }
                                Spacer()
                                if message.urgent {
                                    Text("Urgent", comment: "Indicates that the message is urgent")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 8)
                                        .background(Color.accentColor)
                                        .cornerRadius(.infinity)
                                }
                            }
                            Text(message.date.formatted())
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 2)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                viewModel.deleteMessage(messageId: message.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                viewModel.deleteMessage(messageId: message.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    if viewModel.messages.isEmpty {
                        Text("No messages available.", comment: "Indicates that there are no messages in the channel")
                            .foregroundColor(.gray)
                    }
                }
            }
            .refreshable {
                viewModel.fetchMessages()
            }
        }
        .toolbar {
            ToolbarItem() {
                NavigationLink {
                    ChannelInfoView(channel: viewModel.channel) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            dismiss()
                        }
                    }
                } label: {
                    Image(systemName: "info.circle")
                }
            }
        }
        .navigationTitle(viewModel.channel.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.viewWillAppear()
        }
        .onDisappear {
            viewModel.viewWillDisappear()
        }
    }
}

#Preview {
    NavigationStack {
        ChannelDetailView(channel: Channel(id: "1", name: "General", createdAt: Date(), owners: ["user1"], apiKey: "123"))
    }
}
