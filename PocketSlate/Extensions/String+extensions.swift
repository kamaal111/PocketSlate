//
//  String+extensions.swift
//  PocketSlate
//
//  Created by Kamaal M Farah on 28/05/2023.
//

import Foundation

extension String {
    func fuzzyMatch(@Lowercased _ needle: String) -> Bool {
        guard !needle.isEmpty else { return true }

        var remainder = needle
        for char in lowercased() where char == remainder[remainder.startIndex] {
            remainder.removeFirst()

            if remainder.isEmpty {
                return true
            }
        }

        return false
    }
}
