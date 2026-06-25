//
//  ASPAssetManager.swift
//  AssetSpherePro
//
//  CRUD for assets backed by ASPAssetEntity. Records timeline activities on
//  mutating operations.
//

import CoreData

final class ASPAssetManager {

    static let shared = ASPAssetManager()

    private init() {}

    private var stack: ASPCoreDataStack { .shared }
    private var entity: String { ASPCoreDataStack.Entity.asset }

    // MARK: - Create / Update

    /// Inserts a new asset and logs a "created" activity.
    @discardableResult
    func asp_add(_ model: ASPAssetModel) -> Bool {
        let object = stack.insert(entity)
        Self.apply(model, to: object)
        let saved = stack.save()
        if saved {
            ASPActivityManager.shared.asp_record(type: .createAsset, title: model.assetName)
        }
        return saved
    }

    /// Updates an existing asset (matched by id) and logs an "edited" activity.
    @discardableResult
    func asp_update(_ model: ASPAssetModel) -> Bool {
        guard let object = object(for: model.assetId) else { return false }
        Self.apply(model, to: object)
        let saved = stack.save()
        if saved {
            ASPActivityManager.shared.asp_record(type: .editAsset, title: model.assetName)
        }
        return saved
    }

    /// Inserts without logging — used by demo seeding to control dates precisely.
    @discardableResult
    func asp_addSilently(_ model: ASPAssetModel) -> Bool {
        let object = stack.insert(entity)
        Self.apply(model, to: object)
        return stack.save()
    }

    // MARK: - Delete

    @discardableResult
    func asp_delete(id: String) -> Bool {
        guard let object = object(for: id) else { return false }
        let name = object.value(forKey: "assetName") as? String ?? ""
        stack.delete(object)
        let saved = stack.save()
        if saved {
            ASPActivityManager.shared.asp_record(type: .deleteAsset, title: name)
        }
        return saved
    }

    /// Toggles favorite state and returns the new value.
    @discardableResult
    func asp_toggleFavorite(id: String) -> Bool {
        guard let object = object(for: id) else { return false }
        let current = object.value(forKey: "isFavorite") as? Bool ?? false
        object.setValue(!current, forKey: "isFavorite")
        stack.save()
        return !current
    }

    // MARK: - Read

    func asp_all() -> [ASPAssetModel] {
        let sort = [NSSortDescriptor(key: "assetDate", ascending: false)]
        return stack.fetch(entity, sort: sort).map(Self.map)
    }

    func asp_recent(limit: Int) -> [ASPAssetModel] {
        let sort = [NSSortDescriptor(key: "assetDate", ascending: false)]
        return stack.fetch(entity, sort: sort, limit: limit).map(Self.map)
    }

    func asp_favorites() -> [ASPAssetModel] {
        let predicate = NSPredicate(format: "isFavorite == YES")
        let sort = [NSSortDescriptor(key: "assetDate", ascending: false)]
        return stack.fetch(entity, predicate: predicate, sort: sort).map(Self.map)
    }

    func asp_assets(in category: String) -> [ASPAssetModel] {
        let predicate = NSPredicate(format: "assetCategory == %@", category)
        let sort = [NSSortDescriptor(key: "assetDate", ascending: false)]
        return stack.fetch(entity, predicate: predicate, sort: sort).map(Self.map)
    }

    func asp_search(_ query: String) -> [ASPAssetModel] {
        let trimmed = query.asp_trimmed
        guard !trimmed.isEmpty else { return asp_all() }
        let predicate = NSPredicate(
            format: "assetName CONTAINS[cd] %@ OR assetNote CONTAINS[cd] %@ OR assetCategory CONTAINS[cd] %@",
            trimmed, trimmed, trimmed
        )
        let sort = [NSSortDescriptor(key: "assetDate", ascending: false)]
        return stack.fetch(entity, predicate: predicate, sort: sort).map(Self.map)
    }

    func asp_asset(id: String) -> ASPAssetModel? {
        object(for: id).map(Self.map)
    }

    var asp_count: Int { stack.count(entity) }

    var asp_totalValue: Double {
        asp_all().reduce(0) { $0 + $1.assetValue }
    }

    func asp_count(in category: String) -> Int {
        stack.count(entity, predicate: NSPredicate(format: "assetCategory == %@", category))
    }

    // MARK: - Private

    private func object(for id: String) -> NSManagedObject? {
        stack.fetch(entity, predicate: NSPredicate(format: "assetId == %@", id), limit: 1).first
    }

    private static func apply(_ model: ASPAssetModel, to object: NSManagedObject) {
        object.setValue(model.assetId, forKey: "assetId")
        object.setValue(model.assetName, forKey: "assetName")
        object.setValue(model.assetCategory, forKey: "assetCategory")
        object.setValue(model.assetValue, forKey: "assetValue")
        object.setValue(model.assetNote, forKey: "assetNote")
        object.setValue(model.assetDate, forKey: "assetDate")
        object.setValue(model.assetImagePath, forKey: "assetImagePath")
        object.setValue(model.isFavorite, forKey: "isFavorite")
    }

    private static func map(_ object: NSManagedObject) -> ASPAssetModel {
        ASPAssetModel(
            assetId: object.value(forKey: "assetId") as? String ?? UUID().uuidString,
            assetName: object.value(forKey: "assetName") as? String ?? "",
            assetCategory: object.value(forKey: "assetCategory") as? String ?? "Other",
            assetValue: object.value(forKey: "assetValue") as? Double ?? 0,
            assetNote: object.value(forKey: "assetNote") as? String ?? "",
            assetDate: object.value(forKey: "assetDate") as? Date ?? Date(),
            assetImagePath: object.value(forKey: "assetImagePath") as? String,
            isFavorite: object.value(forKey: "isFavorite") as? Bool ?? false
        )
    }
}
