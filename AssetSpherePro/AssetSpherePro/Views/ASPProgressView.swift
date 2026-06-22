//
//  ASPProgressView.swift
//  AssetSpherePro
//
//  A rounded, gradient-filled progress bar used for storage usage and value
//  share visualizations.
//

import UIKit

final class ASPProgressView: UIView {

    private let trackView = UIView()
    private let fillView = ASPGradientView(colors: ASPTheme.Gradient.accent,
                                           start: CGPoint(x: 0, y: 0.5),
                                           end: CGPoint(x: 1, y: 0.5))
    private var fillWidthConstraint: NSLayoutConstraint!
    private var progress: CGFloat = 0

    init() {
        super.init(frame: .zero)
        asp_setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func asp_setup() {
        translatesAutoresizingMaskIntoConstraints = false

        trackView.translatesAutoresizingMaskIntoConstraints = false
        trackView.backgroundColor = ASPTheme.Color.glassFillStrong
        trackView.layer.cornerRadius = 5
        trackView.clipsToBounds = true
        addSubview(trackView)

        fillView.translatesAutoresizingMaskIntoConstraints = false
        fillView.layer.cornerRadius = 5
        fillView.clipsToBounds = true
        trackView.addSubview(fillView)

        fillWidthConstraint = fillView.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 10),
            trackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            trackView.topAnchor.constraint(equalTo: topAnchor),
            trackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            fillView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
            fillView.topAnchor.constraint(equalTo: trackView.topAnchor),
            fillView.bottomAnchor.constraint(equalTo: trackView.bottomAnchor),
            fillWidthConstraint
        ])
    }

    /// Sets the progress (0...1). Override the fill gradient colors if provided.
    func asp_setProgress(_ value: CGFloat, colors: [CGColor]? = nil, animated: Bool = true) {
        progress = max(0, min(1, value))
        if let colors = colors { fillView.asp_setColors(colors) }
        layoutIfNeeded()
        fillWidthConstraint.constant = trackView.bounds.width * progress
        if animated {
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.9,
                           initialSpringVelocity: 0, options: [.curveEaseOut]) {
                self.layoutIfNeeded()
            }
        } else {
            layoutIfNeeded()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Keep the fill width in sync with the track width on rotation/resizes.
        fillWidthConstraint.constant = trackView.bounds.width * progress
    }
}
