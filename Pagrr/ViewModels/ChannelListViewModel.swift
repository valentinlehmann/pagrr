//
//  ChannelListViewModel.swift
//  Pagrr
//
//  Created by Valentin Lehmann on 01.01.26.
//

import SwiftUI
internal import FirebaseFirestoreInternal
import FirebaseAuth
import FirebaseFirestore

@Observable
class ChannelListViewModel {
    var channels: [Channel] = []
    var isShowingAccountPopover = false
    var isLoading = false
    
    func fetchChannels() {
        isLoading = true;
        
        DatabaseService.shared.fetchChannels { channels in
            Task { @MainActor in
                self.channels = channels.sorted { $0.name < $1.name }
                self.isLoading = false;
            }
        }
    }
    
    func createChannel() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user logged in, cannot create channel")
            return
        }
        
        let id = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        let channel = Channel(id: id, name: String(localized: "New channel", comment: "Name of a newly created channel"), createdAt: Date(), owners: [userId], apiKey: UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased())
        
        self.channels.append(channel)
        self.channels = self.channels.sorted { $0.name < $1.name }
        
        do {
            try DatabaseService.shared.db.collection("channels").document(id).setData(from: channel)
            fetchChannels()
        } catch {
            print("Error creating channel: \(error)")
        }
    }
    
    func deleteChannel(id: String) {
        Task { @MainActor in
            self.channels.removeAll { $0.id == id }
        }
        
        DatabaseService.shared.deleteChannel(id: id)
        
        Task { @MainActor in
            self.fetchChannels()
        }
    }
}

