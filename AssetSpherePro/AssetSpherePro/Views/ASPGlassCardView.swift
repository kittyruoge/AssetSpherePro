//
//  ASPGlassCardView.swift
//  AssetSpherePro
//
//  The signature glassmorphism surface: a blurred translucent panel with a
//  hairline highlight border and large corner radius. Most cards in the app
//  build on top of this.
//

import UIKit

class ASPGlassCardView: UIView {

    /// The blur effect view filling the card.
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    /// A subtle tint laid over the blur to lift the surface.
    private let tintView = UIView()
    /// Content goes here so it sits above blur + tint.
    let contentView = UIView()

    init(cornerRadius: CGFloat = ASPTheme.Layout.cardCornerRadius) {
        super.init(frame: .zero)
        asp_setup(cornerRadius: cornerRadius)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func asp_setup(cornerRadius: CGFloat) {
        backgroundColor = .clear
        layer.cornerRadius = cornerRadius
        layer.cornerCurve = .continuous
        clipsToBounds = true

        blurView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)

        tintView.translatesAutoresizingMaskIntoConstraints = false
        tintView.backgroundColor = ASPTheme.Color.glassFill
        addSubview(tintView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        blurView.asp_pinEdges(to: self)
        tintView.asp_pinEdges(to: self)
        contentView.asp_pinEdges(to: self)

        // Hairline border drawn on the layer.
        layer.borderWidth = 1
        layer.borderColor = ASPTheme.Color.glassBorder.cgColor
    }

    /// Applies a soft outer shadow. Call after the view has a superview; it
    /// disables clipping on a wrapper-friendly basis by drawing the shadow on
    /// the layer (the rounded content stays clipped via the blur subviews).
    func asp_applyShadow() {
        layer.masksToBounds = false
        clipsToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.35
        layer.shadowRadius = 24
        layer.shadowOffset = CGSize(width: 0, height: 12)
        // Re-clip the inner surfaces so the blur keeps its rounded corners.
        blurView.layer.cornerRadius = layer.cornerRadius
        blurView.layer.cornerCurve = .continuous
        blurView.clipsToBounds = true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layer.borderColor = ASPTheme.Color.glassBorder.cgColor
    }
}
