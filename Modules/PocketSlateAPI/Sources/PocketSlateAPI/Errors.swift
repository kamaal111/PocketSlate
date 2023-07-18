//
//  Errors.swift
//
//
//  Created by Kamaal M Farah on 16/07/2023.
//

import Foundation

public enum PocketSlateAPIErrors: Error {
    case badRequest(message: String?)
    case unauthorized(message: String?)
    case unknownError(statusCode: Int, message: String?, context: Error?)
}
