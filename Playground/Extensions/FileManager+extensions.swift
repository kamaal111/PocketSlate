//
//  FileManager+extensions.swift
//  Playground
//
//  Created by Kamaal M Farah on 22/07/2023.
//

import Foundation
import KamaalExtensions

extension FileManager {
    func findDirectoryOrFile(inDirectory directory: URL, searchPath: String) throws -> URL? {
        try contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [])
            .find(by: \.lastPathComponent, is: searchPath)
    }
}
