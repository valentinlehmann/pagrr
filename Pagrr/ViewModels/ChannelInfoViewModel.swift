//
//  ChannelInfoViewModel.swift
//  Pagrr
//
//  Created by Valentin Lehmann on 02.01.26.
//

import SwiftUI
internal import FirebaseFirestoreInternal

@Observable
class ChannelInfoViewModel {
    let channelId: String
    var channel: Channel
    var showApiKey = false
    var editedName = ""
    var newOwnerId = ""
    var newOwnerAlertPresented = false
    private var onNameUpdated: ((String) -> Void)?
    
    init(channelId: String, onNameUpdated: ((String) -> Void)? = nil) {
        self.channelId = channelId
        self.channel = Channel(id: channelId, name: "", createdAt: Date(), owners: [], apiKey: "")
        self.fetchChannel()
        self.onNameUpdated = onNameUpdated
    }
    
    func fetchChannel() {
        DatabaseService.shared.fetchChannel(channelId: channelId) { fetchedChannel in
            guard let fetchedChannel = fetchedChannel else {
                print("Failed to fetch channel with ID \(self.channelId)")
                return
            }
            
            Task { @MainActor in
                self.channel = fetchedChannel
                self.editedName = fetchedChannel.name
            }
        }
    }
    
    func updateChannelName() {
        if editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            print("Channel name cannot be empty")
            editedName = channel.name
            return
        }
        
        if editedName == channel.name {
            return
        }
        
        Task { @MainActor in
            self.channel.name = self.editedName
        }
        
        onNameUpdated?(editedName)
        
        DatabaseService.shared.db.collection("channels").document(channel.id).updateData([
            "name": editedName
        ]) { error in
            if let error = error {
                print("Error updating channel name: \(error)")
                return
            }
            
            print("Updated channel name to \(self.editedName) for channel \(self.channel.id)")
        }
    }
    
    func resetApiKey() {
        let newApiKey = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        
        DatabaseService.shared.db.collection("channels").document(channel.id).updateData([
            "apiKey": newApiKey
        ]) { error in
            if let error = error {
                print("Error resetting API key: \(error)")
                return
            }
            
            Task { @MainActor in
                self.channel.apiKey = newApiKey
                print("Reset API key for channel \(self.channel.id)")
            }
        }
    }
    
    func deleteChannel() {
        DatabaseService.shared.db.collection("channels").document(channel.id).delete { error in
            if let error = error {
                print("Error deleting channel: \(error)")
            } else {
                print("Channel deleted successfully")
            }
        }
    }
    
    func addOwner(_ id: String) {
        if channel.owners.contains(id) {
            return
        }
        
        Task { @MainActor in
            self.channel.owners.append(id)
        }
        
        DatabaseService.shared.db.collection("channels").document(channel.id).updateData([
            "owners": FieldValue.arrayUnion([id])
        ]) { error in
            if let error = error {
                print("Error removing owner: \(error)")
                return
            }
        }
    }

    
    func removeOwner(_ id: String) {
        Task { @MainActor in
            self.channel.owners.removeAll { $0 == id }
        }
        
        DatabaseService.shared.db.collection("channels").document(channel.id).updateData([
            "owners": FieldValue.arrayRemove([id])
        ]) { error in
            if let error = error {
                print("Error removing owner: \(error)")
                return
            }
        }
    }
    
    func promptForNewOwnerId() async -> String? {
        await withCheckedContinuation { continuation in
            let alert = UIAlertController(title: "Add Owner", message: "Enter the user ID of the new owner:", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "User ID"
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                continuation.resume(returning: nil)
            })
            alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
                let userId = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                continuation.resume(returning: userId?.isEmpty == false ? userId : nil)
            })
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func copyConfiguration() {
        UIPasteboard.general.string = """
            curl --location 'https://createnotification-m3eh43zzpq-ew.a.run.app/?channelId=\(channel.id)' \\
            --header 'Content-Type: application/json' \\
            --header 'Authorization: Bearer \(channel.apiKey)' \\
            --data '{
                "title": "\(String(localized: "Test title", comment: "Title of the copied configuration"))",
                "description": "\(String(localized: "Test description", comment: "Description of the copied configuration"))"
            }'
            """
    }
}
