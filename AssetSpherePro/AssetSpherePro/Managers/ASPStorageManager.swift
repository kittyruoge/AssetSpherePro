//
//  ASPStorageManager.swift
//  AssetSpherePro
//
//  Manages on-disk files for asset images, imported documents, and photos.
//  Also persists document/photo metadata to Core Data and reports storage use.
//

import UIKit
import CoreData

final class ASPStorageManager {

    static let shared = ASPStorageManager()

    private init() {
        asp_createDirectoriesIfNeeded()
    }

    private var stack: ASPCoreDataStack { .shared }
    private let fileManager = FileManager.default

    // MARK: - Directories

    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var imagesDirectory: URL { documentsDirectory.appendingPathComponent("ASPImages", isDirectory: true) }
    private var filesDirectory: URL { documentsDirectory.appendingPathComponent("ASPFiles", isDirectory: true) }
    private var photosDirectory: URL { documentsDirectory.appendingPathComponent("ASPPhotos", isDirectory: true) }

    private func asp_createDirectoriesIfNeeded() {
        for dir in [imagesDirectory, filesDirectory, photosDirectory] {
            if !fileManager.fileExists(atPath: dir.path) {
                try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
            }
        }
    }

    // MARK: - Asset images

    /// Saves a JPEG for an asset and returns the stored relative file name.
    func asp_saveAssetImage(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let name = "asset_\(UUID().uuidString).jpg"
        let url = imagesDirectory.appendingPathComponent(name)
        do {
            try data.write(to: url)
            return name
        } catch {
            return nil
        }
    }

    func asp_loadAssetImage(_ name: String?) -> UIImage? {
        guard let name = name else { return nil }
        let url = imagesDirectory.appendingPathComponent(name)
        return UIImage(contentsOfFile: url.path)
    }

    // MARK: - Photo vault

    /// Saves a photo into the vault, records metadata, logs activity.
    @discardableResult
    func asp_savePhoto(_ image: UIImage, logActivity: Bool = true) -> ASPPhotoModel? {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return nil }
        let name = "photo_\(UUID().uuidString).jpg"
        let url = photosDirectory.appendingPathComponent(name)
        guard (try? data.write(to: url)) != nil else { return nil }

        let object = stack.insert(ASPCoreDataStack.Entity.photo)
        let id = UUID().uuidString
        object.setValue(id, forKey: "photoId")
        object.setValue(name, forKey: "photoPath")
        object.setValue(Date(), forKey: "createDate")
        stack.save()

        if logActivity {
            ASPActivityManager.shared.asp_record(type: .importPhoto, title: "Photo added to vault")
        }
        return ASPPhotoModel(photoId: id, photoPath: name, createDate: Date())
    }

    func asp_loadPhoto(_ name: String) -> UIImage? {
        UIImage(contentsOfFile: photosDirectory.appendingPathComponent(name).path)
    }

    func asp_allPhotos() -> [ASPPhotoModel] {
        let sort = [NSSortDescriptor(key: "createDate", ascending: false)]
        return stack.fetch(ASPCoreDataStack.Entity.photo, sort: sort).map { object in
            ASPPhotoModel(
                photoId: object.value(forKey: "photoId") as? String ?? "",
                photoPath: object.value(forKey: "photoPath") as? String ?? "",
                createDate: object.value(forKey: "createDate") as? Date ?? Date()
            )
        }
    }

    @discardableResult
    func asp_deletePhoto(id: String) -> Bool {
        let matches = stack.fetch(ASPCoreDataStack.Entity.photo,
                                  predicate: NSPredicate(format: "photoId == %@", id), limit: 1)
        guard let object = matches.first else { return false }
        if let name = object.value(forKey: "photoPath") as? String {
            try? fileManager.removeItem(at: photosDirectory.appendingPathComponent(name))
        }
        stack.delete(object)
        return stack.save()
    }

    var asp_photoCount: Int { stack.count(ASPCoreDataStack.Entity.photo) }

    // MARK: - Document center

    /// Imports a document from a source URL into the app's files directory.
    @discardableResult
    func asp_importDocument(from sourceURL: URL, logActivity: Bool = true) -> ASPDocumentModel? {
        let originalName = sourceURL.lastPathComponent
        let storedName = "\(UUID().uuidString)_\(originalName)"
        let destination = filesDirectory.appendingPathComponent(storedName)

        let needsStop = sourceURL.startAccessingSecurityScopedResource()
        defer { if needsStop { sourceURL.stopAccessingSecurityScopedResource() } }

        do {
            if fileManager.fileExists(atPath: destination.path) {
                try fileManager.removeItem(at: destination)
            }
            try fileManager.copyItem(at: sourceURL, to: destination)
        } catch {
            return nil
        }

        let object = stack.insert(ASPCoreDataStack.Entity.document)
        let id = UUID().uuidString
        object.setValue(id, forKey: "documentId")
        object.setValue(originalName, forKey: "documentName")
        object.setValue(storedName, forKey: "documentPath")
        object.setValue(Date(), forKey: "createDate")
        stack.save()

        if logActivity {
            ASPActivityManager.shared.asp_record(type: .importDocument, title: originalName)
        }
        return ASPDocumentModel(documentId: id, documentName: originalName,
                                documentPath: storedName, createDate: Date())
    }

    /// Creates a placeholder text document (used by demo seeding).
    @discardableResult
    func asp_createTextDocument(named name: String, contents: String, date: Date) -> ASPDocumentModel? {
        let storedName = "\(UUID().uuidString)_\(name)"
        let url = filesDirectory.appendingPathComponent(storedName)
        guard (try? contents.write(to: url, atomically: true, encoding: .utf8)) != nil else { return nil }

        let object = stack.insert(ASPCoreDataStack.Entity.document)
        let id = UUID().uuidString
        object.setValue(id, forKey: "documentId")
        object.setValue(name, forKey: "documentName")
        object.setValue(storedName, forKey: "documentPath")
        object.setValue(date, forKey: "createDate")
        stack.save()
        return ASPDocumentModel(documentId: id, documentName: name, documentPath: storedName, createDate: date)
    }

    func asp_documentURL(_ storedName: String) -> URL {
        filesDirectory.appendingPathComponent(storedName)
    }

    func asp_allDocuments() -> [ASPDocumentModel] {
        let sort = [NSSortDescriptor(key: "createDate", ascending: false)]
        return stack.fetch(ASPCoreDataStack.Entity.document, sort: sort).map { object in
            ASPDocumentModel(
                documentId: object.value(forKey: "documentId") as? String ?? "",
                documentName: object.value(forKey: "documentName") as? String ?? "",
                documentPath: object.value(forKey: "documentPath") as? String ?? "",
                createDate: object.value(forKey: "createDate") as? Date ?? Date()
            )
        }
    }

    @discardableResult
    func asp_deleteDocument(id: String) -> Bool {
        let matches = stack.fetch(ASPCoreDataStack.Entity.document,
                                  predicate: NSPredicate(format: "documentId == %@", id), limit: 1)
        guard let object = matches.first else { return false }
        if let name = object.value(forKey: "documentPath") as? String {
            try? fileManager.removeItem(at: filesDirectory.appendingPathComponent(name))
        }
        stack.delete(object)
        return stack.save()
    }

    var asp_documentCount: Int { stack.count(ASPCoreDataStack.Entity.document) }

    // MARK: - Storage usage

    /// Total bytes used by all app-managed files.
    func asp_totalStorageBytes() -> Int64 {
        [imagesDirectory, filesDirectory, photosDirectory]
            .reduce(0) { $0 + directorySize($1) }
    }

    private func directorySize(_ url: URL) -> Int64 {
        guard let contents = try? fileManager.contentsOfDirectory(
            at: url, includingPropertiesForKeys: [.fileSizeKey]) else { return 0 }
        return contents.reduce(0) { total, fileURL in
            let size = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            return total + Int64(size)
        }
    }
}
