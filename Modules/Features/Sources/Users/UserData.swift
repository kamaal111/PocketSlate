//
//  UserData.swift
//
//
//  Created by Kamaal M Farah on 12/06/2023.
//

import SwiftUI
import AppLocales
import KamaalLogger
import KamaalSettings
import KamaalExtensions

private let logger = KamaalLogger(from: UserData.self, failOnError: true)

public final class UserData: ObservableObject {
    @Published private var showLogs = true
    @Published private var appColor = AppColor(
        id: UUID(uuidString: "d3256bc6-84a4-4717-a970-9d2d3a1724b4")!,
        name: AppLocales.getText(.DEFAULT_COLOR),
        color: Color("AccentColor")
    )
    @Published public private(set) var appLocale = Locale(identifier: "en")

    private static var currentLocale = Locale.current

    public var settingsConfiguration: SettingsConfiguration {
        var feedback: SettingsConfiguration.FeedbackConfiguration?
        if let githubToken = SecretsJSON.shared.content?.githubToken {
            #if os(macOS)
            let deviceLabel = "macOS"
            #else
            let deviceLabel = UIDevice.current.userInterfaceIdiom == .pad ? "iPadOS" : "iOS"
            #endif
            feedback = .init(
                token: githubToken,
                username: "Kamaal111",
                repoName: "PocketSlate",
                additionalLabels: ["in app feedback", deviceLabel]
            )
        }

        return .init(
            feedback: feedback,
            color: colorConfiguration,
            acknowledgements: AcknowledgementsJSON.shared.content,
            showLogs: showLogs
        )
    }

    private var colorConfiguration: SettingsConfiguration.ColorsConfiguration {
        .init(colors: [appColor], currentColor: appColor)
    }
}
