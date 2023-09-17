//
//  AppDelegate_macOS.swift
//  PocketSlate
//
//  Created by Kamaal M Farah on 25/06/2023.
//

#if os(macOS)
import Cocoa
import CloudKit
import CloudSyncing
import KamaalLogger

private let logger = KamaalLogger(from: AppDelegate.self, failOnError: true)

final class AppDelegate: NSObject { }

extension AppDelegate: NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let application = notification.object as? NSApplication else { return }

        application.registerForRemoteNotifications()

        Task {
            do {
                try await Skypiea.shared.subscripeToAll()
            } catch {
                logger.warning("failed to subscribe to iCloud subscriptions; error='\(error)'")
            }
        }
    }

    func application(_: NSApplication, didReceiveRemoteNotification userInfo: [String: Any]) {
        if let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) {
            logger.info("notification received; \(notification)")
            NotificationCenter.default.post(name: .iCloudChanges, object: notification)
        }
    }
}
#endif
