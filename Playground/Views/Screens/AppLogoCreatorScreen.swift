//
//  AppLogoCreatorScreen.swift
//  Playground
//
//  Created by Kamaal M Farah on 22/07/2023.
//

import AppUI
import SwiftUI
import KamaalUI

let PLAYGROUND_SELECTABLE_COLORS: [Color] = [
    .red,
    .green,
    .yellow,
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
                viewModel.logoView(size: 150)
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
        @Published var hasCurves = true
        @Published var exportLogoSize = "400" {
            didSet {
                let filteredExportLogoSize = exportLogoSize.filter(\.isNumber)
                if exportLogoSize != filteredExportLogoSize {
                    exportLogoSize = filteredExportLogoSize
                }
            }
        }

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

        func logoView(size: CGFloat) -> some View {
            AppLogo(
                size: size,
                backgroundColor: hasABackground ? backgroundColor : .white.opacity(0),
                curvedCornersSize: hasCurves ? curvedCornersSize : 0
            )
        }

        #if canImport(Cocoa) && !targetEnvironment(macCatalyst)
        func exportLogo() { }

        func exportLogoAsIconSet() { }

        @MainActor
        private func logoViewImageData(size: CGFloat) async throws -> Data {
            let view = logoView(size: size)
            let data = ImageRenderer(content: view)
                .nsImage?
                .tiffRepresentation
            guard let data else { throw Errors.conversionFailure }

            let pngRepresentation = NSBitmapImageRep(data: data)?
                .representation(using: .png, properties: [:])
            guard let pngRepresentation else { throw Errors.conversionFailure }

            return pngRepresentation
        }
        #endif
    }
}

#Preview {
    AppLogoCreatorScreen()
}
