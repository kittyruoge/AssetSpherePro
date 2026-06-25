//
//  ASPDemoData.swift
//  AssetSpherePro
//
//  Generates a rich first-run dataset (assets, activities, documents, photos)
//  so a freshly signed-in account — especially the review account — shows a
//  fully populated dashboard. Runs once per account.
//

import UIKit

enum ASPDemoData {

    /// Seeds demo content. Safe to call once per account; the caller guards
    /// against repeat invocation.
    static func seed() {
        let calendar = Calendar.current
        let now = Date()
        func daysAgo(_ days: Int) -> Date {
            calendar.date(byAdding: .day, value: -days, to: now) ?? now
        }

        // MARK: Assets
        let assets: [ASPAssetModel] = [
            ASPAssetModel(assetName: "MacBook Pro 16\"", assetCategory: "Electronics",
                          assetValue: 3499, assetNote: "M-series, 36GB RAM, 1TB SSD. Primary work machine.",
                          assetDate: daysAgo(210), isFavorite: true),
            ASPAssetModel(assetName: "iPhone Pro", assetCategory: "Electronics",
                          assetValue: 1199, assetNote: "256GB, titanium finish.",
                          assetDate: daysAgo(150), isFavorite: true),
            ASPAssetModel(assetName: "Tesla Model Y", assetCategory: "Vehicles",
                          assetValue: 48990, assetNote: "Long Range, dual motor. Purchased new.",
                          assetDate: daysAgo(420), isFavorite: true),
            ASPAssetModel(assetName: "Camera Kit", assetCategory: "Collections",
                          assetValue: 2750, assetNote: "Mirrorless body + 3 prime lenses + tripod.",
                          assetDate: daysAgo(95)),
            ASPAssetModel(assetName: "Home Office Setup", assetCategory: "Workspace",
                          assetValue: 4200, assetNote: "Standing desk, ergonomic chair, dual 4K monitors.",
                          assetDate: daysAgo(60)),
            ASPAssetModel(assetName: "Downtown Apartment", assetCategory: "Property",
                          assetValue: 320000, assetNote: "Two-bedroom unit. Estimated market value.",
                          assetDate: daysAgo(540), isFavorite: true),
            ASPAssetModel(assetName: "Cloud & Software", assetCategory: "Subscriptions",
                          assetValue: 1080, assetNote: "Annual creative + productivity suite licenses.",
                          assetDate: daysAgo(30)),
            ASPAssetModel(assetName: "Mechanical Watch", assetCategory: "Collections",
                          assetValue: 5600, assetNote: "Automatic movement, sapphire crystal.",
                          assetDate: daysAgo(12))
        ]

        for asset in assets {
            ASPAssetManager.shared.asp_addSilently(asset)
        }

        // MARK: Activities (timeline)
        let activityManager = ASPActivityManager.shared
        activityManager.asp_record(type: .createAsset, title: "Downtown Apartment", date: daysAgo(540))
        activityManager.asp_record(type: .createAsset, title: "Tesla Model Y", date: daysAgo(420))
        activityManager.asp_record(type: .createAsset, title: "MacBook Pro 16\"", date: daysAgo(210))
        activityManager.asp_record(type: .editAsset, title: "Home Office Setup", date: daysAgo(58))
        activityManager.asp_record(type: .createAsset, title: "Cloud & Software", date: daysAgo(30))
        activityManager.asp_record(type: .createAsset, title: "Mechanical Watch", date: daysAgo(12))

        // MARK: Documents
        let storage = ASPStorageManager.shared
        storage.asp_createTextDocument(
            named: "Apartment Deed.txt",
            contents: "AssetSphere Pro demo document.\nProperty: Downtown Apartment\nThis is sample placeholder content.",
            date: daysAgo(540))
        storage.asp_createTextDocument(
            named: "Vehicle Registration.txt",
            contents: "AssetSphere Pro demo document.\nVehicle: Tesla Model Y\nThis is sample placeholder content.",
            date: daysAgo(420))
        storage.asp_createTextDocument(
            named: "Warranty - MacBook Pro.txt",
            contents: "AssetSphere Pro demo document.\nDevice: MacBook Pro 16\"\nCoverage: 1 year limited warranty.",
            date: daysAgo(210))
        storage.asp_createTextDocument(
            named: "Insurance Summary.txt",
            contents: "AssetSphere Pro demo document.\nPolicy covering high-value collection items.",
            date: daysAgo(40))

        // MARK: Photos — render simple gradient placeholders so the vault isn't empty.
        let photoColors: [(UIColor, UIColor)] = [
            (ASPTheme.Color.accent, ASPTheme.Color.accentSecondary),
            (ASPTheme.Color.accentPink, ASPTheme.Color.accent),
            (ASPTheme.Color.positive, ASPTheme.Color.accentSecondary),
            (ASPTheme.Color.warning, ASPTheme.Color.accentPink)
        ]
        for (top, bottom) in photoColors {
            if let image = gradientImage(top: top, bottom: bottom) {
                storage.asp_savePhoto(image, logActivity: false)
            }
        }
    }

    /// Renders a diagonal gradient image used as a demo vault photo.
    private static func gradientImage(top: UIColor, bottom: UIColor) -> UIImage? {
        let size = CGSize(width: 600, height: 600)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let cg = context.cgContext
            let colors = [top.cgColor, bottom.cgColor] as CFArray
            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors,
                locations: [0, 1]) else { return }
            cg.drawLinearGradient(gradient,
                                  start: .zero,
                                  end: CGPoint(x: size.width, y: size.height),
                                  options: [])
        }
    }
}
