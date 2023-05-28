//
//  Crudable.swift
//
//
//  Created by Kamaal Farah on 28/05/2023.
//

import Foundation

public protocol Crudable: Identifiable {
    associatedtype Payload
    associatedtype ReturnType: Hashable
    associatedtype Context
    associatedtype OwnType: Crudable

    var asReturnType: ReturnType { get }
    var id: UUID { get }

    func delete() throws
    func update(_ payload: Payload) throws -> OwnType
    static func list(from context: Context) throws -> [OwnType]
    static func find(by id: UUID, from context: Context) throws -> OwnType?
    static func filter(ids: [UUID], from context: Context) throws -> [OwnType]
    static func create(_ payload: Payload, from context: Context) throws -> OwnType
    static func create(_ payload: Payload, from context: Context, save: Bool) throws -> OwnType
    static func batchDelete(ids: [UUID], on context: Context) throws
}
