//
//  ASPStatisticsManager.swift
//  AssetSpherePro
//
//  Computes aggregate statistics for the analytics screens.
//

import Foundation

struct ASPCategoryStat {
    let category: String
    let count: Int
    let totalValue: Double
    /// Share of the overall portfolio value (0...1).
    let valueShare: Double
}

struct ASPMonthlyStat {
    let label: String       // e.g. "Mar"
    let total: Double
    let monthStart: Date
}

final class ASPStatisticsManager {

    static let shared = ASPStatisticsManager()

    private init() {}

    private var assetManager: ASPAssetManager { .shared }

    // MARK: - Totals

    var asp_totalAssets: Int { assetManager.asp_count }

    var asp_totalValue: Double { assetManager.asp_totalValue }

    var asp_categoriesUsed: Int {
        Set(assetManager.asp_all().map { $0.assetCategory }).count
    }

    var asp_averageValue: Double {
        let assets = assetManager.asp_all()
        guard !assets.isEmpty else { return 0 }
        return assets.reduce(0) { $0 + $1.assetValue } / Double(assets.count)
    }

    var asp_highestValueAsset: ASPAssetModel? {
        assetManager.asp_all().max(by: { $0.assetValue < $1.assetValue })
    }

    // MARK: - Category breakdown

    /// Per-category counts and value shares, sorted by total value descending.
    func asp_categoryStats() -> [ASPCategoryStat] {
        let assets = assetManager.asp_all()
        let total = assets.reduce(0) { $0 + $1.assetValue }
        var buckets: [String: (count: Int, value: Double)] = [:]

        for asset in assets {
            var bucket = buckets[asset.assetCategory] ?? (0, 0)
            bucket.count += 1
            bucket.value += asset.assetValue
            buckets[asset.assetCategory] = bucket
        }

        return buckets.map { key, value in
            ASPCategoryStat(
                category: key,
                count: value.count,
                totalValue: value.value,
                valueShare: total > 0 ? value.value / total : 0
            )
        }
        .sorted { $0.totalValue > $1.totalValue }
    }

    // MARK: - Trend over time

    /// Cumulative portfolio value at the end of each of the last `months` months.
    func asp_monthlyTrend(months: Int = 6) -> [ASPMonthlyStat] {
        let calendar = Calendar.current
        let assets = assetManager.asp_all()
        let now = Date()

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        formatter.locale = Locale(identifier: "en_US")

        var result: [ASPMonthlyStat] = []

        for offset in stride(from: months - 1, through: 0, by: -1) {
            guard let monthDate = calendar.date(byAdding: .month, value: -offset, to: now),
                  let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate)),
                  let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthStart) else {
                continue
            }
            // Cumulative value of every asset acquired before the month ends.
            let total = assets
                .filter { $0.assetDate < nextMonth }
                .reduce(0) { $0 + $1.assetValue }
            result.append(ASPMonthlyStat(label: formatter.string(from: monthStart),
                                         total: total, monthStart: monthStart))
        }
        return result
    }

    // MARK: - Recent activity counts

    func asp_recentActivityCount(days: Int = 7) -> Int {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return ASPActivityManager.shared.asp_allActivities()
            .filter { $0.date >= cutoff }
            .count
    }
}
