//
//  NotificationName+extensions.swift
//
//
//  Created by Kamaal M Farah on 27/06/2023.
//

import Foundation

extension Notification.Name {
    public static let iCloudChanges = makeNotificationName(withKey: "icloud_changes")

    private static func makeNotificationName(withKey key: String) -> Notification.Name {
        Notification.Name("\(Bundle.main.bundleIdentifier!).notifications.\(key)")
    }
}
