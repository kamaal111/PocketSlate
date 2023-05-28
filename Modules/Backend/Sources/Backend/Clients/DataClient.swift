//
//  DataClient.swift
//
//
//  Created by Kamaal Farah on 28/05/2023.
//

import Models
import CoreData
import CDPersist
import Foundation

public enum DataClientErrors: Error {
    case fetchFailure(context: Error?)
    case createFailure(context: Error)
    case deleteFailure(context: Error)
    case updateFailure(context: Error)
}

public class DataClient<Model: Crudable> {
    public typealias Model = Model.Type

    let context: Model.Context

    init(context: Model.Context) {
        self.context = context
    }

    public func create(_ payload: Model.Payload) -> Result<Model.ReturnType, DataClientErrors> {
        createUnmapped(payload, save: true).map { $0.asReturnType as! Model.ReturnType }
    }

    func createUnmapped(_ payload: Model.Payload, save: Bool) -> Result<Model.OwnType, DataClientErrors> {
        let item: Model.OwnType
        do {
            item = try Model.create(payload, from: context, save: save)
        } catch {
            return .failure(.createFailure(context: error))
        }

        return .success(item)
    }

    public func update(by id: UUID, with payload: Model.Payload) -> Result<Model.ReturnType, DataClientErrors> {
        updateUnmapped(by: id, with: payload)
            .map { $0.asReturnType as! Model.ReturnType }
    }

    func updateUnmapped(by id: UUID, with payload: Model.Payload) -> Result<Model.OwnType, DataClientErrors> {
        let findResult = findUnmapped(by: id)
        let item: Model.OwnType?
        switch findResult {
        case let .failure(failure):
            return .failure(failure)
        case let .success(success):
            item = success
        }

        guard let item else { return .failure(.fetchFailure(context: .none)) }

        let updatedItem: Model.OwnType.OwnType
        do {
            updatedItem = try item.update(payload as! Model.OwnType.Payload)
        } catch {
            return .failure(.updateFailure(context: error))
        }

        return .success(updatedItem as! Model.OwnType)
    }

    public func list() -> Result<[Model.ReturnType], DataClientErrors> {
        let items: [Model.OwnType]
        do {
            items = try Model.list(from: context)
        } catch {
            return .failure(.fetchFailure(context: error))
        }

        return .success(items.compactMap { $0.asReturnType as? Model.ReturnType })
    }

    public func find(by id: UUID) -> Result<Model.ReturnType?, DataClientErrors> {
        findUnmapped(by: id).map { $0?.asReturnType as? Model.ReturnType }
    }

    private func findUnmapped(by id: UUID) -> Result<Model.OwnType?, DataClientErrors> {
        let item: Model.OwnType?
        do {
            item = try Model.find(by: id, from: context)
        } catch {
            return .failure(.fetchFailure(context: error))
        }

        return .success(item)
    }
}
