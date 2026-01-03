//
//  ChannelDetailViewModel.swift
//  Pagrr
//
//  Created by Valentin Lehmann on 01.01.26.
//

internal import FirebaseFirestoreInternal
import FirebaseFirestore
import SwiftUI

@Observable
class ChannelDetailViewModel {
    var channel: Channel
    var messages: [ChannelMessage] = []
    var subscription: ListenerRegistration?
    
    init(channel: Channel) {
        self.channel = channel
    }
    
    func fetchMessages() {
        DatabaseService.shared.db.collection("channels/\(channel.id)/messages")
            .order(by: "date", descending: true)
            .limit(to: 5)
            .getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching messages: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No messages found")
                return
            }
                
                
            
            Task { @MainActor in
                self.messages = documents.map { doc in
                    try! doc.data(as: ChannelMessage.self)
                }
            }
        }
    }
    
    func viewWillAppear() {
        subscription = DatabaseService.shared.db.collection("channels/\(channel.id)/messages")
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error listening for message updates: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No messages found in listener")
                    return
                }
                
                Task { @MainActor in
                    self.messages = documents.map { doc in
                        try! doc.data(as: ChannelMessage.self)
                    }
                }
            }
    }
    
    func viewWillDisappear() {
        subscription?.remove()
        subscription = nil
    }
    
    func deleteMessage(messageId: String) {
        self.messages.removeAll { $0.id == messageId }
        
        DatabaseService.shared.db.collection("channels/\(channel.id)/messages").document(messageId).delete { error in
            if let error = error {
                print("Error deleting message: \(error)")
                return
            }
            
            Task { @MainActor in
                print("Deleted message with ID \(messageId) from channel \(self.channel.id)")
            }
        }
    }
}
