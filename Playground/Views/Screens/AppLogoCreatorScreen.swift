//
//  AppLogoCreatorScreen.swift
//  Playground
//
//  Created by Kamaal M Farah on 22/07/2023.
//

import AppUI
import SwiftUI
import KamaalUI
import KamaalLogger

private let logger = KamaalLogger(from: AppLogoCreatorScreen.self, failOnError: true)

let PLAYGROUND_SELECTABLE_COLORS: [Color] = [
    Color("LogoBackgroundColor"),
    .white,
    .black,
]

struct AppLogoCreatorScreen: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        KScrollableForm {
            KJustStack {
                logoSection
                customizationSection
            }
            #if os(macOS)
            .padding(.all, .medium)
            .ktakeSizeEagerly(alignment: .topLeading)
            #endif
        }
    }

    private var logoSection: some View {
        KSection(header: "Logo") {
            HStack(alignment: .top) {
                viewModel.logoView(
                    size: viewModel.previewLogoSize,
                    cornerRadius: viewModel.hasCurves ? viewModel.curvedCornersSize : 0
                )
                Spacer()
                VStack(alignment: .leading) {
                    HStack {
                        KFloatingTextField(
                            text: $viewModel.exportLogoSize,
                            title: "Export logo size",
                            textFieldType: .numbers
                        )
                        HStack {
                            Button(action: { viewModel.setRecommendedLogoSize() }) {
                                Text("Logo size")
                                    .foregroundColor(.accentColor)
                            }
                            .disabled(viewModel.disableLogoSizeButton)
                            Button(action: { viewModel.setRecommendedAppIconSize() }) {
                                Text("Icon size")
                                    .foregroundColor(.accentColor)
                            }
                            .disabled(viewModel.disableAppIconSizeButton)
                        }
                        .padding(.bottom, -(AppSizes.small.rawValue))
                    }
                    #if canImport(Cocoa) && !targetEnvironment(macCatalyst)
                    HStack {
                        Button(action: viewModel.exportLogo) {
                            Text("Export logo")
                                .foregroundColor(.accentColor)
                        }
                        Button(action: viewModel.exportLogoAsIconSet) {
                            Text("Export logo as IconSet")
                                .foregroundColor(.accentColor)
                        }
                    }
                    #endif
                }
            }
        }
    }

    private var customizationSection: some View {
        KSection(header: "Customization") {
            AppLogoColorFormRow(title: "Has a background") {
                Toggle(viewModel.hasABackground ? "Yup" : "Nope", isOn: $viewModel.hasABackground)
            }
            .padding(.bottom, .medium)
            .padding(.vertical, .small)
            AppLogoColorSelector(color: $viewModel.backgroundColor, title: "Background color")
                .disabled(viewModel.disabledBackgroundColorButtons)
                .padding(.bottom, .medium)
            AppLogoColorSelector(color: $viewModel.translatedTextColor, title: "Translated text color")
                .padding(.bottom, .medium)
            AppLogoColorSelector(
                color: $viewModel.translatedTextBackgroundColor,
                title: "Translated text background color"
            )
            .padding(.bottom, .medium)
            AppLogoColorFormRow(title: "Has curves") {
                Toggle(viewModel.hasCurves ? "Yup" : "Nope", isOn: $viewModel.hasCurves)
            }
            .padding(.bottom, .medium)
            .disabled(viewModel.disableHasCurveToggle)
            AppLogoColorFormRow(title: "Curve size") {
                Stepper("\(Int(viewModel.curvedCornersSize))", value: $viewModel.curvedCornersSize)
            }
            .disabled(viewModel.disableCurvesSize)
        }
    }
}

extension AppLogoCreatorScreen {
    final class ViewModel: ObservableObject {
        @Published var curvedCornersSize: CGFloat = 16
        @Published var hasABackground = true
        @Published var backgroundColor = PLAYGROUND_SELECTABLE_COLORS[0]
        @Published var translatedTextColor = PLAYGROUND_SELECTABLE_COLORS[1]
        @Published var translatedTextBackgroundColor = PLAYGROUND_SELECTABLE_COLORS[2]
        @Published var hasCurves = true
        @Published var exportLogoSize = "400" {
            didSet {
                let filteredExportLogoSize = exportLogoSize.filter(\.isNumber)
                if exportLogoSize != filteredExportLogoSize {
                    exportLogoSize = filteredExportLogoSize
                }
            }
        }

        let previewLogoSize: CGFloat = 150

        enum Errors: Error {
            case conversionFailure
        }

        var disabledBackgroundColorButtons: Bool {
            !hasABackground
        }

        var disableLogoSizeButton: Bool {
            exportLogoSize == "400"
        }

        var disableAppIconSizeButton: Bool {
            exportLogoSize == "800"
        }

        var disableHasCurveToggle: Bool {
            !hasABackground
        }

        var disableCurvesSize: Bool {
            !hasCurves || disableHasCurveToggle
        }

        @MainActor
        func setRecommendedLogoSize() {
            withAnimation { exportLogoSize = "400" }
        }

        @MainActor
        func setRecommendedAppIconSize() {
            withAnimation { exportLogoSize = "800" }
        }

        func logoView(size: CGFloat, cornerRadius: CGFloat) -> some View {
            AppLogo(
                size: size,
                backgroundColor: hasABackground ? backgroundColor : .white.opacity(0),
                translatedTextColor: translatedTextColor,
                translatedTextBackgroundColor: translatedTextBackgroundColor,
                curvedCornersSize: cornerRadius
            )
        }

        #if os(macOS)
        func exportLogo() {
            Task {
                let logoViewData = try! await getLogoViewImageData()

                let logoName = "logo.png"
                let (savePanelResult, panel) = await SavePanel.savePanel(filename: logoName)
                guard savePanelResult == .ok else { return }

                let saveURL = await panel.url!
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: saveURL.path) {
                    try? fileManager.removeItem(at: saveURL)
                }

                try! logoViewData.write(to: saveURL)
            }
        }

        func exportLogoAsIconSet() {
            Task {
                let fileManager = FileManager.default
                let temporaryDirectory = fileManager.temporaryDirectory
                let logoViewData = try! await getLogoViewImageData()
                let appIconScriptResult = try! Shell
                    .runAppIconGenerator(input: logoViewData, output: temporaryDirectory)
                    .get()
                assert(appIconScriptResult.splitLines.last?.hasPrefix("done creating icons") == true)

                let iconSetName = "AppIcon.appiconset"
                let iconSetURL = try! fileManager
                    .findDirectoryOrFile(inDirectory: temporaryDirectory, searchPath: iconSetName)!
                defer { try? fileManager.removeItem(at: iconSetURL) }

                let (savePanelResult, panel) = await SavePanel.savePanel(filename: iconSetName)
                guard savePanelResult == .ok else { return }

                let saveURL = await panel.url!
                if fileManager.fileExists(atPath: saveURL.path) {
                    try? fileManager.removeItem(at: saveURL)
                }

                try! fileManager.moveItem(at: iconSetURL, to: saveURL)
            }
        }

        @MainActor
        private func getLogoViewImageData() async throws -> Data {
            let data = ImageRenderer(content: logoToExport)
                .nsImage?
                .tiffRepresentation
            guard let data else { throw Errors.conversionFailure }

            let pngRepresentation = NSBitmapImageRep(data: data)?
                .representation(using: .png, properties: [:])
            guard let pngRepresentation else { throw Errors.conversionFailure }

            return pngRepresentation
        }
        #endif

        private var logoToExport: some View {
            let size = Double(exportLogoSize)!.cgFloat
            return logoView(size: size, cornerRadius: hasCurves ? curvedCornersSize * (size / previewLogoSize) : 0)
        }
    }
}

#Preview {
    AppLogoCreatorScreen()
}
