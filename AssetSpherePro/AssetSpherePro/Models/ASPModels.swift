//
//  ASPModels.swift
//  AssetSpherePro
//
//  Plain value types used throughout the UI layer. Managers translate between
//  these structs and Core Data managed objects so view controllers never touch
//  NSManagedObject directly.
//

import Foundation

// MARK: - Asset

struct ASPAssetModel {
    var assetId: String
    var assetName: String
    var assetCategory: String
    var assetValue: Double
    var assetNote: String
    var assetDate: Date
    var assetImagePath: String?
    var isFavorite: Bool

    init(assetId: String = UUID().uuidString,
         assetName: String = "",
         assetCategory: String = ASPCategory.all.first ?? "Other",
         assetValue: Double = 0,
         assetNote: String = "",
         assetDate: Date = Date(),
         assetImagePath: String? = nil,
         isFavorite: Bool = false) {
        self.assetId = assetId
        self.assetName = assetName
        self.assetCategory = assetCategory
        self.assetValue = assetValue
        self.assetNote = assetNote
        self.assetDate = assetDate
        self.assetImagePath = assetImagePath
        self.isFavorite = isFavorite
    }
}

// MARK: - User

struct ASPUserModel {
    var userId: String
    var username: String
    var email: String
    var avatar: String?
    var registerDate: Date
    var lastLoginDate: Date?

    init(userId: String = UUID().uuidString,
         username: String = "",
         email: String = "",
         avatar: String? = nil,
         registerDate: Date = Date(),
         lastLoginDate: Date? = nil) {
        self.userId = userId
        self.username = username
        self.email = email
        self.avatar = avatar
        self.registerDate = registerDate
        self.lastLoginDate = lastLoginDate
    }
}

// MARK: - Activity

enum ASPActivityType: String, CaseIterable {
    case createAsset = "Created Asset"
    case editAsset = "Edited Asset"
    case deleteAsset = "Deleted Asset"
    case importDocument = "Imported Document"
    case importPhoto = "Imported Photo"
    case login = "Signed In"

    /// SF Symbol name representing the activity type.
    var symbol: String {
        switch self {
        case .createAsset:    return "plus.circle.fill"
        case .editAsset:      return "pencil.circle.fill"
        case .deleteAsset:    return "trash.circle.fill"
        case .importDocument: return "doc.circle.fill"
        case .importPhoto:    return "photo.circle.fill"
        case .login:          return "person.crop.circle.fill"
        }
    }
}

struct ASPActivityModel {
    var activityId: String
    var title: String
    var type: String
    var date: Date

    var activityType: ASPActivityType? { ASPActivityType(rawValue: type) }

    init(activityId: String = UUID().uuidString,
         title: String = "",
         type: ASPActivityType = .createAsset,
         date: Date = Date()) {
        self.activityId = activityId
        self.title = title
        self.type = type.rawValue
        self.date = date
    }
}

// MARK: - Document

struct ASPDocumentModel {
    var documentId: String
    var documentName: String
    var documentPath: String
    var createDate: Date

    /// Lowercased file extension (without the dot).
    var fileExtension: String {
        (documentName as NSString).pathExtension.lowercased()
    }

    init(documentId: String = UUID().uuidString,
         documentName: String = "",
         documentPath: String = "",
         createDate: Date = Date()) {
        self.documentId = documentId
        self.documentName = documentName
        self.documentPath = documentPath
        self.createDate = createDate
    }
}

// MARK: - Photo

struct ASPPhotoModel {
    var photoId: String
    var photoPath: String
    var createDate: Date

    init(photoId: String = UUID().uuidString,
         photoPath: String = "",
         createDate: Date = Date()) {
        self.photoId = photoId
        self.photoPath = photoPath
        self.createDate = createDate
    }
}

// MARK: - Categories

enum ASPCategory {
    /// The default set of categories shipped with the app.
    static let all: [String] = [
        "Electronics",
        "Vehicles",
        "Property",
        "Collections",
        "Workspace",
        "Subscriptions",
        "Other"
    ]

    /// SF Symbol icon for a given category.
    static func symbol(for category: String) -> String {
        switch category {
        case "Electronics":   return "laptopcomputer"
        case "Vehicles":      return "car.fill"
        case "Property":      return "house.fill"
        case "Collections":   return "sparkles"
        case "Workspace":     return "briefcase.fill"
        case "Subscriptions": return "creditcard.fill"
        default:              return "shippingbox.fill"
        }
    }
}
