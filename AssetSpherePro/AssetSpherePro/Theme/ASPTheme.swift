//
//  ASPTheme.swift
//  AssetSpherePro
//
//  Central design system: colors, fonts, gradients, spacing, glass effects.
//  Style direction: Apple Wallet + VisionOS + Glassmorphism, dark theme.
//

import UIKit

enum ASPTheme {

    // MARK: - Colors

    enum Color {
        /// Deep near-black base used at the bottom of the background gradient.
        static let backgroundBottom = UIColor(red: 0.04, green: 0.05, blue: 0.09, alpha: 1.0)
        /// Slightly lifted indigo used at the top of the background gradient.
        static let backgroundTop = UIColor(red: 0.09, green: 0.10, blue: 0.18, alpha: 1.0)

        /// Primary accent (violet).
        static let accent = UIColor(red: 0.55, green: 0.45, blue: 0.98, alpha: 1.0)
        /// Secondary accent (cyan/teal) used in gradients.
        static let accentSecondary = UIColor(red: 0.30, green: 0.78, blue: 0.98, alpha: 1.0)
        /// Tertiary accent (pink) used for highlights.
        static let accentPink = UIColor(red: 0.98, green: 0.45, blue: 0.78, alpha: 1.0)

        static let positive = UIColor(red: 0.30, green: 0.85, blue: 0.55, alpha: 1.0)
        static let negative = UIColor(red: 0.98, green: 0.42, blue: 0.42, alpha: 1.0)
        static let warning = UIColor(red: 0.98, green: 0.78, blue: 0.35, alpha: 1.0)

        static let textPrimary = UIColor(white: 1.0, alpha: 0.96)
        static let textSecondary = UIColor(white: 1.0, alpha: 0.62)
        static let textTertiary = UIColor(white: 1.0, alpha: 0.38)

        /// Hairline border for glass surfaces.
        static let glassBorder = UIColor(white: 1.0, alpha: 0.18)
        /// Fill tint layered over the blur for glass surfaces.
        static let glassFill = UIColor(white: 1.0, alpha: 0.06)
        static let glassFillStrong = UIColor(white: 1.0, alpha: 0.12)

        /// Category color lookup keyed by category name.
        static func category(_ name: String) -> UIColor {
            switch name {
            case "Electronics":   return UIColor(red: 0.36, green: 0.62, blue: 0.98, alpha: 1.0)
            case "Vehicles":      return UIColor(red: 0.98, green: 0.55, blue: 0.35, alpha: 1.0)
            case "Property":      return UIColor(red: 0.42, green: 0.82, blue: 0.62, alpha: 1.0)
            case "Collections":   return UIColor(red: 0.85, green: 0.52, blue: 0.95, alpha: 1.0)
            case "Workspace":     return UIColor(red: 0.98, green: 0.75, blue: 0.38, alpha: 1.0)
            case "Subscriptions": return UIColor(red: 0.36, green: 0.80, blue: 0.92, alpha: 1.0)
            default:              return UIColor(red: 0.62, green: 0.65, blue: 0.74, alpha: 1.0)
            }
        }
    }

    // MARK: - Fonts

    enum Font {
        static func largeTitle() -> UIFont { rounded(34, .bold) }
        static func title() -> UIFont { rounded(26, .bold) }
        static func headline() -> UIFont { rounded(20, .semibold) }
        static func body() -> UIFont { rounded(16, .regular) }
        static func bodyMedium() -> UIFont { rounded(16, .medium) }
        static func caption() -> UIFont { rounded(13, .regular) }
        static func captionMedium() -> UIFont { rounded(13, .medium) }
        static func number(_ size: CGFloat) -> UIFont { rounded(size, .bold) }
        static func mono(_ size: CGFloat) -> UIFont {
            UIFont.monospacedDigitSystemFont(ofSize: size, weight: .bold)
        }

        /// Rounded variant of the system font when available, falling back gracefully.
        static func rounded(_ size: CGFloat, _ weight: UIFont.Weight) -> UIFont {
            let base = UIFont.systemFont(ofSize: size, weight: weight)
            guard let descriptor = base.fontDescriptor.withDesign(.rounded) else { return base }
            return UIFont(descriptor: descriptor, size: size)
        }
    }

    // MARK: - Layout

    enum Layout {
        static let screenInset: CGFloat = 20
        static let cardSpacing: CGFloat = 16
        static let cardCornerRadius: CGFloat = 26
        static let smallCornerRadius: CGFloat = 16
        static let buttonHeight: CGFloat = 54
        static let fieldHeight: CGFloat = 54
    }

    // MARK: - Gradients

    enum Gradient {
        static let background: [CGColor] = [
            Color.backgroundTop.cgColor,
            Color.backgroundBottom.cgColor
        ]

        static let accent: [CGColor] = [
            Color.accent.cgColor,
            Color.accentSecondary.cgColor
        ]

        static let warm: [CGColor] = [
            Color.accentPink.cgColor,
            Color.accent.cgColor
        ]

        static let positive: [CGColor] = [
            Color.positive.cgColor,
            Color.accentSecondary.cgColor
        ]
    }
}
