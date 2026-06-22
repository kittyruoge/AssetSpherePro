//
//  ASPAnalyticsViewController.swift
//  AssetSpherePro
//
//  Statistics dashboard: totals, value trend chart, category breakdown with
//  share bars, and recent-activity counts.
//

import UIKit

final class ASPAnalyticsViewController: ASPBaseViewController {

    private var contentStack: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Analytics"
        contentStack = asp_makeScrollingStack(topInset: 12, spacing: ASPTheme.Layout.cardSpacing)
        asp_reload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        asp_reload()
    }

    private func asp_reload() {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let stats = ASPStatisticsManager.shared

        if stats.asp_totalAssets == 0 {
            let empty = ASPEmptyView()
            empty.asp_configure(icon: "chart.bar.xaxis", title: "No Data Yet",
                                message: "Add assets to see your portfolio analytics.")
            contentStack.addArrangedSubview(empty)
            return
        }

        // Totals row.
        let totalsRow = UIStackView()
        totalsRow.axis = .horizontal
        totalsRow.distribution = .fillEqually
        totalsRow.spacing = 10
        totalsRow.translatesAutoresizingMaskIntoConstraints = false
        totalsRow.heightAnchor.constraint(equalToConstant: 120).isActive = true

        let assetsCard = ASPStatisticCardView()
        assetsCard.asp_configure(icon: "shippingbox.fill", value: Double(stats.asp_totalAssets),
                                 title: "Total Assets", isCurrency: false)
        let valueCard = ASPStatisticCardView()
        valueCard.asp_configure(icon: "dollarsign.circle.fill", value: stats.asp_totalValue,
                                title: "Total Value", isCurrency: true, gradient: ASPTheme.Gradient.positive)
        totalsRow.addArrangedSubview(assetsCard)
        totalsRow.addArrangedSubview(valueCard)
        contentStack.addArrangedSubview(totalsRow)

        let totalsRow2 = UIStackView()
        totalsRow2.axis = .horizontal
        totalsRow2.distribution = .fillEqually
        totalsRow2.spacing = 10
        totalsRow2.translatesAutoresizingMaskIntoConstraints = false
        totalsRow2.heightAnchor.constraint(equalToConstant: 120).isActive = true

        let avgCard = ASPStatisticCardView()
        avgCard.asp_configure(icon: "function", value: stats.asp_averageValue,
                              title: "Average Value", isCurrency: true, gradient: ASPTheme.Gradient.warm)
        let activityCard = ASPStatisticCardView()
        activityCard.asp_configure(icon: "clock.arrow.circlepath", value: Double(stats.asp_recentActivityCount(days: 7)),
                                   title: "Activity (7d)", isCurrency: false,
                                   gradient: [ASPTheme.Color.accentSecondary.cgColor, ASPTheme.Color.accent.cgColor])
        totalsRow2.addArrangedSubview(avgCard)
        totalsRow2.addArrangedSubview(activityCard)
        contentStack.addArrangedSubview(totalsRow2)

        // Trend chart.
        let trendHeader = ASPHeaderView()
        trendHeader.asp_configure(title: "Value Trend", subtitle: "Last 6 months")
        contentStack.addArrangedSubview(trendHeader)

        let chartCard = ASPGlassCardView(cornerRadius: ASPTheme.Layout.cardCornerRadius)
        chartCard.translatesAutoresizingMaskIntoConstraints = false
        let chart = ASPChartView()
        let trend = stats.asp_monthlyTrend(months: 6)
        chart.asp_configure(values: trend.map { $0.total }, labels: trend.map { $0.label })
        chartCard.contentView.addSubview(chart)
        NSLayoutConstraint.activate([
            chart.topAnchor.constraint(equalTo: chartCard.contentView.topAnchor, constant: 18),
            chart.leadingAnchor.constraint(equalTo: chartCard.contentView.leadingAnchor, constant: 18),
            chart.trailingAnchor.constraint(equalTo: chartCard.contentView.trailingAnchor, constant: -18),
            chart.bottomAnchor.constraint(equalTo: chartCard.contentView.bottomAnchor, constant: -18),
            chart.heightAnchor.constraint(equalToConstant: 160)
        ])
        contentStack.addArrangedSubview(chartCard)

        // Category breakdown.
        let breakdownHeader = ASPHeaderView()
        breakdownHeader.asp_configure(title: "By Category")
        contentStack.addArrangedSubview(breakdownHeader)

        let breakdownCard = ASPGlassCardView(cornerRadius: ASPTheme.Layout.cardCornerRadius)
        breakdownCard.translatesAutoresizingMaskIntoConstraints = false
        let breakdownStack = UIStackView()
        breakdownStack.axis = .vertical
        breakdownStack.spacing = 16
        breakdownStack.translatesAutoresizingMaskIntoConstraints = false
        breakdownCard.contentView.addSubview(breakdownStack)
        breakdownStack.asp_pinEdges(to: breakdownCard.contentView, inset: 18)

        for stat in stats.asp_categoryStats() {
            breakdownStack.addArrangedSubview(asp_categoryRow(stat))
        }
        contentStack.addArrangedSubview(breakdownCard)
    }

    private func asp_categoryRow(_ stat: ASPCategoryStat) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let nameLabel = UILabel()
        nameLabel.text = stat.category
        nameLabel.font = ASPTheme.Font.bodyMedium()
        nameLabel.textColor = ASPTheme.Color.textPrimary
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = UILabel()
        valueLabel.text = "\(ASPFormat.currency(stat.totalValue))  ·  \(Int(stat.valueShare * 100))%"
        valueLabel.font = ASPTheme.Font.caption()
        valueLabel.textColor = ASPTheme.Color.textSecondary
        valueLabel.textAlignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        let bar = ASPProgressView()
        let color = ASPTheme.Color.category(stat.category)
        bar.asp_setProgress(CGFloat(stat.valueShare),
                            colors: [color.cgColor, color.withAlphaComponent(0.6).cgColor])

        container.addSubview(nameLabel)
        container.addSubview(valueLabel)
        container.addSubview(bar)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: nameLabel.trailingAnchor, constant: 8),
            bar.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            bar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            bar.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }
}
