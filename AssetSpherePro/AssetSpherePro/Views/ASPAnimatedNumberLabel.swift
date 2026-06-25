//
//  ASPAnimatedNumberLabel.swift
//  AssetSpherePro
//
//  A label that animates counting from one value to another, with optional
//  currency formatting. Used for the dynamic dashboard numbers.
//

import UIKit

final class ASPAnimatedNumberLabel: UILabel {

    /// When true, values are rendered as USD currency; otherwise as integers.
    var isCurrency: Bool = false

    private var displayLink: CADisplayLink?
    private var startValue: Double = 0
    private var targetValue: Double = 0
    private var startTime: CFTimeInterval = 0
    private let duration: CFTimeInterval = 0.9

    override init(frame: CGRect) {
        super.init(frame: frame)
        font = ASPTheme.Font.mono(28)
        textColor = ASPTheme.Color.textPrimary
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Animates from the current value to `value`.
    func asp_animate(to value: Double) {
        displayLink?.invalidate()
        startValue = currentValue
        targetValue = value
        startTime = CACurrentMediaTime()

        let link = CADisplayLink(target: self, selector: #selector(asp_tick))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    /// Sets a value immediately without animation.
    func asp_set(_ value: Double) {
        displayLink?.invalidate()
        displayLink = nil
        currentValue = value
        render(value)
    }

    private var currentValue: Double = 0

    @objc private func asp_tick() {
        let elapsed = CACurrentMediaTime() - startTime
        let progress = min(1, elapsed / duration)
        // Ease-out cubic for a refined settle.
        let eased = 1 - pow(1 - progress, 3)
        let value = startValue + (targetValue - startValue) * eased
        currentValue = value
        render(value)

        if progress >= 1 {
            displayLink?.invalidate()
            displayLink = nil
            currentValue = targetValue
            render(targetValue)
        }
    }

    private func render(_ value: Double) {
        text = isCurrency ? ASPFormat.currency(value) : String(Int(value.rounded()))
    }
}
