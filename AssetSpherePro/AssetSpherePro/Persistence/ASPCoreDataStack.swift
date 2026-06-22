//
//  ASPCoreDataStack.swift
//  AssetSpherePro
//
//  Programmatic Core Data stack. The managed object model is defined in code
//  (no .xcdatamodeld file) so the whole persistence layer lives in source and
//  compiles cleanly with file-system-synchronized project groups.
//

import CoreData

final class ASPCoreDataStack {

    static let shared = ASPCoreDataStack()

    private init() {}

    // MARK: - Entity names

    enum Entity {
        static let asset = "ASPAssetEntity"
        static let user = "ASPUserEntity"
        static let activity = "ASPActivityEntity"
        static let document = "ASPDocumentEntity"
        static let photo = "ASPPhotoEntity"
    }

    // MARK: - Model

    private lazy var managedObjectModel: NSManagedObjectModel = {
        let model = NSManagedObjectModel()

        let assetEntity = Self.makeEntity(
            name: Entity.asset,
            attributes: [
                ("assetId", .stringAttributeType, false),
                ("assetName", .stringAttributeType, false),
                ("assetCategory", .stringAttributeType, false),
                ("assetValue", .doubleAttributeType, false),
                ("assetNote", .stringAttributeType, true),
                ("assetDate", .dateAttributeType, false),
                ("assetImagePath", .stringAttributeType, true),
                ("isFavorite", .booleanAttributeType, false)
            ]
        )

        let userEntity = Self.makeEntity(
            name: Entity.user,
            attributes: [
                ("userId", .stringAttributeType, false),
                ("username", .stringAttributeType, false),
                ("email", .stringAttributeType, false),
                ("password", .stringAttributeType, true),
                ("avatar", .stringAttributeType, true),
                ("registerDate", .dateAttributeType, false),
                ("lastLoginDate", .dateAttributeType, true)
            ]
        )

        let activityEntity = Self.makeEntity(
            name: Entity.activity,
            attributes: [
                ("activityId", .stringAttributeType, false),
                ("title", .stringAttributeType, false),
                ("type", .stringAttributeType, false),
                ("date", .dateAttributeType, false)
            ]
        )

        let documentEntity = Self.makeEntity(
            name: Entity.document,
            attributes: [
                ("documentId", .stringAttributeType, false),
                ("documentName", .stringAttributeType, false),
                ("documentPath", .stringAttributeType, false),
                ("createDate", .dateAttributeType, false)
            ]
        )

        let photoEntity = Self.makeEntity(
            name: Entity.photo,
            attributes: [
                ("photoId", .stringAttributeType, false),
                ("photoPath", .stringAttributeType, false),
                ("createDate", .dateAttributeType, false)
            ]
        )

        model.entities = [assetEntity, userEntity, activityEntity, documentEntity, photoEntity]
        return model
    }()

    private static func makeEntity(
        name: String,
        attributes: [(String, NSAttributeType, Bool)]
    ) -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = name
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)

        entity.properties = attributes.map { (attrName, type, optional) in
            let attribute = NSAttributeDescription()
            attribute.name = attrName
            attribute.attributeType = type
            attribute.isOptional = optional
            return attribute
        }
        return entity
    }

    // MARK: - Container

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AssetSpherePro", managedObjectModel: managedObjectModel)
        container.loadPersistentStores { _, error in
            if let error = error {
                // Persistent store failure is unrecoverable for this app; log clearly.
                assertionFailure("ASP Core Data store failed to load: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Save

    @discardableResult
    func save() -> Bool {
        guard context.hasChanges else { return true }
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            assertionFailure("ASP Core Data save failed: \(error)")
            return false
        }
    }

    // MARK: - Fetch helpers

    func fetch(_ entityName: String,
               predicate: NSPredicate? = nil,
               sort: [NSSortDescriptor]? = nil,
               limit: Int? = nil) -> [NSManagedObject] {
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        request.predicate = predicate
        request.sortDescriptors = sort
        if let limit = limit { request.fetchLimit = limit }
        do {
            return try context.fetch(request)
        } catch {
            assertionFailure("ASP fetch failed for \(entityName): \(error)")
            return []
        }
    }

    func count(_ entityName: String, predicate: NSPredicate? = nil) -> Int {
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        request.predicate = predicate
        return (try? context.count(for: request)) ?? 0
    }

    func insert(_ entityName: String) -> NSManagedObject {
        NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
    }

    func delete(_ object: NSManagedObject) {
        context.delete(object)
    }
}
