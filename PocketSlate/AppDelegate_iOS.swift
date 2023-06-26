//
//  AppDelegate_iOS.swift
//  PocketSlate
//
//  Created by Kamaal M Farah on 25/06/2023.
//

#if os(iOS)
import UIKit
import CloudKit
import CloudSyncing
import KamaalLogger

private let logger = KamaalLogger(from: AppDelegate.self, failOnError: true)

final class AppDelegate: NSObject {
    private let userNotificationCenter: UNUserNotificationCenter = .current()
}

extension AppDelegate: UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        application.registerForRemoteNotifications()

        #if !targetEnvironment(simulator)
        Task {
            do {
                try await Skypiea.shared.subscripeToAll()
            } catch {
                logger.error(label: "failed to subscribe to iCloud subscriptions", error: error)
            }
        }
        #endif

        return true
    }

    func application(
        _: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        if let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) {
            logger.info("notification received; \(notification)")
            completionHandler(.newData)
        }
    }
}
#endif
