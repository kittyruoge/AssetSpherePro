//
//  ASPActivityManager.swift
//  AssetSpherePro
//
//  Records and reads timeline activities backed by ASPActivityEntity.
//

import CoreData

final class ASPActivityManager {

    static let shared = ASPActivityManager()

    private init() {}

    private var stack: ASPCoreDataStack { .shared }

    // MARK: - Record

    /// Logs an activity of the given type with a descriptive title.
    func asp_record(type: ASPActivityType, title: String) {
        let object = stack.insert(ASPCoreDataStack.Entity.activity)
        object.setValue(UUID().uuidString, forKey: "activityId")
        object.setValue(title, forKey: "title")
        object.setValue(type.rawValue, forKey: "type")
        object.setValue(Date(), forKey: "date")
        stack.save()
    }

    /// Logs an activity at a specific date (used when seeding demo data).
    func asp_record(type: ASPActivityType, title: String, date: Date) {
        let object = stack.insert(ASPCoreDataStack.Entity.activity)
        object.setValue(UUID().uuidString, forKey: "activityId")
        object.setValue(title, forKey: "title")
        object.setValue(type.rawValue, forKey: "type")
        object.setValue(date, forKey: "date")
        stack.save()
    }

    // MARK: - Read

    /// Returns activities sorted newest-first, optionally limited.
    func asp_allActivities(limit: Int? = nil) -> [ASPActivityModel] {
        let sort = [NSSortDescriptor(key: "date", ascending: false)]
        return stack.fetch(ASPCoreDataStack.Entity.activity, sort: sort, limit: limit)
            .map(Self.map)
    }

    var asp_count: Int {
        stack.count(ASPCoreDataStack.Entity.activity)
    }

    // MARK: - Mapping

    private static func map(_ object: NSManagedObject) -> ASPActivityModel {
        ASPActivityModel(
            activityId: object.value(forKey: "activityId") as? String ?? UUID().uuidString,
            title: object.value(forKey: "title") as? String ?? "",
            type: ASPActivityType(rawValue: object.value(forKey: "type") as? String ?? "") ?? .createAsset,
            date: object.value(forKey: "date") as? Date ?? Date()
        )
    }
}
