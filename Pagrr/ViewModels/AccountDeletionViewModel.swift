//
//  AccountDeletionViewModel.swift
//  Pagrr
//
//  Created by Valentin Lehmann on 02.01.26.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import CryptoKit
import AuthenticationServices

@Observable
class AccountDeletionViewModel: NSObject, ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {
    var channelsFetched = false
    var channels: [Channel] = []
    
    func fetchChannels() {
        DatabaseService.shared.fetchChannels { fetchedChannels in
            Task { @MainActor in
                self.channels = fetchedChannels
                self.channelsFetched = true
            }
        }
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        #if os(iOS)
        return ASPresentationAnchor(windowScene: UIApplication.shared.connectedScenes.first as! UIWindowScene)
        #elseif os(macOS)
        return NSApplication.shared.windows.first!
        #endif
    }
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
        let nonce = AuthService.shared.randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = AuthService.shared.sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                           rawNonce: nonce,
                                                           fullName: appleIDCredential.fullName)
            
            if let currentUser = Auth.auth().currentUser {
                currentUser.reauthenticate(with: credential) { (authResult, error) in
                    if let error = error {
                        // Error. If error.code == .MissingOrInvalidNonce, make sure
                        // you're sending the SHA256-hashed nonce as a hex string with
                        // your request to Apple.
                        print(error.localizedDescription)
                        return
                    }
                    
                    self.deleteAccount()
                }
            } else {
                Auth.auth().signIn(with: credential) { (authResult, error) in
                    if let error = error {
                        // Error. If error.code == .MissingOrInvalidNonce, make sure
                        // you're sending the SHA256-hashed nonce as a hex string with
                        // your request to Apple.
                        print(error.localizedDescription)
                        return
                    }
                    
                    self.deleteAccount()
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
    func deleteAccount() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user logged in, cannot delete account")
            return
        }
        
        channels.forEach { channel in
            if channel.owners.count == 1 {
                DatabaseService.shared.deleteChannel(id: channel.id)
            } else {
                DatabaseService.shared.db.collection("channels").document(channel.id).updateData([
                    "owners": FieldValue.arrayRemove([currentUser.uid])
                ]) { error in
                    if let error = error {
                        print("Error removing user from channel owners: \(error)")
                    }
                }
            }
        }
        
        DatabaseService.shared.db.collection("notificationTokens").document(currentUser.uid).delete { error in
            if let error = error {
                print("Error deleting user document: \(error)")
            } else {
                print("User document deleted successfully")
            }
        }
        
        currentUser.delete { error in
            if let error = error {
                print("Error deleting user account: \(error)")
            } else {
                print("User account deleted successfully")
            }
        }
    }
}
