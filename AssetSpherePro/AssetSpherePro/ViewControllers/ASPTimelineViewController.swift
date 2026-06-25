//
//  ASPTimelineViewController.swift
//  AssetSpherePro
//
//  A chronological feed of activities: created/edited/deleted assets, imported
//  documents and photos. Grouped by relative day with a vertical connector.
//

import UIKit

final class ASPTimelineViewController: ASPBaseViewController {

    private var contentStack: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Timeline"
        navigationItem.largeTitleDisplayMode = .never
        contentStack = asp_makeScrollingStack(topInset: 12, spacing: 10)
        asp_reload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        asp_reload()
    }

    private func asp_reload() {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let activities = ASPActivityManager.shared.asp_allActivities()

        if activities.isEmpty {
            let empty = ASPEmptyView()
            empty.asp_configure(icon: "clock", title: "No Activity",
                                message: "Your asset history will appear here as you add and edit items.")
            contentStack.addArrangedSubview(empty)
            return
        }

        // Group by day.
        let calendar = Calendar.current
        var grouped: [Date: [ASPActivityModel]] = [:]
        for activity in activities {
            let day = calendar.startOfDay(for: activity.date)
            grouped[day, default: []].append(activity)
        }

        let sortedDays = grouped.keys.sorted(by: >)
        for day in sortedDays {
            let header = UILabel()
            header.text = Self.dayLabel(day)
            header.font = ASPTheme.Font.captionMedium()
            header.textColor = ASPTheme.Color.textTertiary
            header.translatesAutoresizingMaskIntoConstraints = false
            contentStack.addArrangedSubview(header)
            contentStack.setCustomSpacing(8, after: header)

            for activity in grouped[day] ?? [] {
                let card = ASPActivityCardView()
                card.asp_configure(activity: activity)
                contentStack.addArrangedSubview(card)
            }
            // Spacer between day groups.
            let spacer = UIView()
            spacer.heightAnchor.constraint(equalToConstant: 6).isActive = true
            contentStack.addArrangedSubview(spacer)
        }
    }

    private static func dayLabel(_ day: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(day) { return "TODAY" }
        if calendar.isDateInYesterday(day) { return "YESTERDAY" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: day).uppercased()
    }
}
