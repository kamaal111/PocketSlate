//
//  SavePanel.swift
//  Playground
//
//  Created by Kamaal M Farah on 22/07/2023.
//

#if os(macOS)
import Cocoa

enum SavePanelStatus: Equatable {
    case ok
    case cancel
    case unknown(response: NSApplication.ModalResponse)
}

struct SavePanel {
    private init() { }

    static func savePanel(filename: String) async -> (SavePanelStatus, NSSavePanel) {
        await withCheckedContinuation { continuation in
            save(filename: filename) { result, panel in
                continuation.resume(returning: (result, panel))
            }
        }
    }

    private static func save(
        filename: String,
        beginHandler: @escaping (_ status: SavePanelStatus, _ panel: NSSavePanel) -> Void
    ) {
        DispatchQueue.main.async {
            let panel = NSSavePanel()
            panel.canCreateDirectories = true
            panel.showsTagField = true
            panel.nameFieldStringValue = filename
            panel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.modalPanelWindow)))
            panel.begin(completionHandler: { result in
                let status: SavePanelStatus
                switch result {
                case .cancel, .cancel, .continue, .stop:
                    status = .cancel
                case .OK:
                    status = .ok
                default:
                    status = .unknown(response: result)
                }
                beginHandler(status, panel)
            })
        }
    }
}
#endif
