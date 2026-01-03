//
//  MessagingService.swift
//  Pagrr
//
//  Created by Valentin Lehmann on 01.01.26.
//

import FirebaseMessaging
import FirebaseAuth
internal import FirebaseFirestoreInternal

class MessagingService: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    static let shared = MessagingService()
    
    func configure() {
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else {
            print("Firebase registration token is nil")
            return
        }
        
        saveToken(fcmToken)
    }
    
    func loadToken() {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                self.saveToken(token)
            }
        }
    }
    
    func saveToken(_ token: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user logged in, cannot save token")
            return
        }
        
        DatabaseService.shared.db.collection("notificationTokens").document(userId).setData([
            "token": token,
            "type": "ios",
        ])
    }
    
    func deleteToken() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user logged in, cannot delete token")
            return
        }
        
        DatabaseService.shared.db.collection("notificationTokens").document(userId).delete { error in
            if let error = error {
                print("Error deleting FCM registration token: \(error)")
            } else {
                print("FCM registration token deleted successfully")
            }
        }
    }
    
    // Receive displayed notifications for iOS 10+ devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
    -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // ...
        
        if let aps = userInfo["aps"] as? [String: Any] {
            aps.forEach { key, value in
                print("APS Key: \(key) Value: \(value)")
            }
        } else if let apsAnyHashable = userInfo["aps"] as? [AnyHashable: Any] {
            apsAnyHashable.forEach { key, value in
                print("APS Key: \(key) Value: \(value)")
            }
        } else {
            print("APS payload missing or in unexpected format")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        // Note: UNNotificationPresentationOptions.alert has been deprecated.
        return [.list, .banner, .sound]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        // ...
        
        
        // Print full message.
        print(userInfo)
    }
}
