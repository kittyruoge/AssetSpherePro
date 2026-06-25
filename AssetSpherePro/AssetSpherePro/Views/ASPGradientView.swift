//
//  ASPGradientView.swift
//  AssetSpherePro
//
//  A view whose backing layer is a CAGradientLayer. Used for the global
//  background and for accent fills.
//

import UIKit

final class ASPGradientView: UIView {

    override class var layerClass: AnyClass { CAGradientLayer.self }

    private var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    /// Creates a gradient view.
    /// - Parameters:
    ///   - colors: CGColors top→bottom (or along the start/end points).
    ///   - start: Unit start point. Defaults to top.
    ///   - end: Unit end point. Defaults to bottom.
    init(colors: [CGColor],
         start: CGPoint = CGPoint(x: 0.5, y: 0),
         end: CGPoint = CGPoint(x: 0.5, y: 1)) {
        super.init(frame: .zero)
        gradientLayer.colors = colors
        gradientLayer.startPoint = start
        gradientLayer.endPoint = end
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func asp_setColors(_ colors: [CGColor]) {
        gradientLayer.colors = colors
    }

    func asp_setPoints(start: CGPoint, end: CGPoint) {
        gradientLayer.startPoint = start
        gradientLayer.endPoint = end
    }
}
