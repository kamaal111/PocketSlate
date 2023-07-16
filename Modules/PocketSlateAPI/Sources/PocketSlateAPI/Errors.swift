//
//  Errors.swift
//
//
//  Created by Kamaal M Farah on 16/07/2023.
//

import Foundation

public enum PocketSlateAPIErrors: Error {
    case unknownError(statusCode: Int)
}
