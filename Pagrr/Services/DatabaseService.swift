//
//  DatabaseService.swift
//  Pagrr
//
//  Created by Valentin Lehmann on 01.01.26.
//

import FirebaseFirestore
import FirebaseAuth

struct DatabaseService {
    static let shared = DatabaseService()
    let db = Firestore.firestore()
    
    func fetchChannel(channelId: String, completion: @escaping (Channel?) -> Void) {
        let docRef = db.collection("channels").document(channelId)
        docRef.getDocument { document, error in
            if let document = document, document.exists {
                Task { @MainActor in
                    do {
                        let channel = try document.data(as: Channel.self)
                        completion(channel)
                    } catch {
                        print("Error decoding channel: \(error)")
                        completion(nil)
                    }
                }
            } else {
                print("Channel does not exist")
                completion(nil)
            }
        }
    }
    
    func fetchChannels(completion: @escaping ([Channel]) -> Void) {
        db.collection("channels")
            .whereField("owners", arrayContains: Auth.auth().currentUser?.uid ?? "")
            .order(by: "name", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching channels: \(error)")
                    completion([])
                }
                
                guard let documents = snapshot?.documents else {
                    print("No channels found")
                    completion([])
                    return
                }
                
                Task { @MainActor in
                    completion(documents.compactMap { doc in
                        try? doc.data(as: Channel.self)
                    })
                }
            }
    }
    
    func deleteChannel(id: String) {
        DatabaseService.shared.db.collection("channels").document(id).delete { error in
            if let error = error {
                print("Error deleting channel: \(error)")
            } else {
                print("Channel deleted successfully")
            }
        }
    }
}
