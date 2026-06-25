//
//  ASPChartView.swift
//  AssetSpherePro
//
//  A lightweight bar chart drawn with CoreGraphics for the analytics trend.
//  No third-party dependencies.
//

import UIKit

final class ASPChartView: UIView {

    private var values: [Double] = []
    private var labels: [String] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func asp_configure(values: [Double], labels: [String]) {
        self.values = values
        self.labels = labels
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard !values.isEmpty, let context = UIGraphicsGetCurrentContext() else { return }

        let labelHeight: CGFloat = 18
        let chartRect = CGRect(x: 0, y: 0, width: rect.width, height: rect.height - labelHeight)
        let maxValue = max(values.max() ?? 1, 1)

        let count = values.count
        let spacing: CGFloat = 10
        let totalSpacing = spacing * CGFloat(count - 1)
        let barWidth = (chartRect.width - totalSpacing) / CGFloat(count)

        let topColor = ASPTheme.Color.accent
        let bottomColor = ASPTheme.Color.accentSecondary

        for (index, value) in values.enumerated() {
            let ratio = CGFloat(value / maxValue)
            let barHeight = max(4, chartRect.height * ratio)
            let x = CGFloat(index) * (barWidth + spacing)
            let y = chartRect.maxY - barHeight
            let barRect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
            let path = UIBezierPath(roundedRect: barRect, cornerRadius: min(8, barWidth / 2))

            context.saveGState()
            path.addClip()
            let colors = [topColor.cgColor, bottomColor.cgColor] as CFArray
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                         colors: colors, locations: [0, 1]) {
                context.drawLinearGradient(gradient,
                                           start: CGPoint(x: barRect.midX, y: barRect.minY),
                                           end: CGPoint(x: barRect.midX, y: barRect.maxY),
                                           options: [])
            }
            context.restoreGState()

            // Month label under each bar.
            if index < labels.count {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10, weight: .medium),
                    .foregroundColor: ASPTheme.Color.textTertiary
                ]
                let text = labels[index] as NSString
                let size = text.size(withAttributes: attributes)
                let textX = x + (barWidth - size.width) / 2
                text.draw(at: CGPoint(x: textX, y: chartRect.maxY + 4), withAttributes: attributes)
            }
        }
    }
}
