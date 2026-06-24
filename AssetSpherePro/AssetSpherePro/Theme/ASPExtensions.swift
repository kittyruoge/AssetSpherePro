//
//  ASPExtensions.swift
//  AssetSpherePro
//
//  Shared UIKit conveniences used across the app.
//

import UIKit

// MARK: - Auto Layout helpers

extension UIView {
    /// Adds a subview that opts out of autoresizing-mask constraints.
    func asp_addSubview(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
    }

    /// Pins all four edges to the given view with an optional uniform inset.
    func asp_pinEdges(to other: UIView, inset: CGFloat = 0) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: other.leadingAnchor, constant: inset),
            trailingAnchor.constraint(equalTo: other.trailingAnchor, constant: -inset),
            topAnchor.constraint(equalTo: other.topAnchor, constant: inset),
            bottomAnchor.constraint(equalTo: other.bottomAnchor, constant: -inset)
        ])
    }
}

// MARK: - Color helpers

extension UIColor {
    /// Linearly interpolates between two colors. `t` is clamped to 0...1.
    static func asp_lerp(_ from: UIColor, _ to: UIColor, _ t: CGFloat) -> UIColor {
        let clamped = max(0, min(1, t))
        var fr: CGFloat = 0, fg: CGFloat = 0, fb: CGFloat = 0, fa: CGFloat = 0
        var tr: CGFloat = 0, tg: CGFloat = 0, tb: CGFloat = 0, ta: CGFloat = 0
        from.getRed(&fr, green: &fg, blue: &fb, alpha: &fa)
        to.getRed(&tr, green: &tg, blue: &tb, alpha: &ta)
        return UIColor(
            red: fr + (tr - fr) * clamped,
            green: fg + (tg - fg) * clamped,
            blue: fb + (tb - fb) * clamped,
            alpha: fa + (ta - fa) * clamped
        )
    }
}

// MARK: - Currency / number formatting

enum ASPFormat {
    private static let currencyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "USD"
        f.maximumFractionDigits = 0
        return f
    }()

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        f.locale = Locale(identifier: "en_US")
        return f
    }()

    private static let relativeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d, HH:mm"
        f.locale = Locale(identifier: "en_US")
        return f
    }()

    static func currency(_ value: Double) -> String {
        currencyFormatter.string(from: NSNumber(value: value)) ?? "$0"
    }

    static func date(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }

    static func dateTime(_ date: Date) -> String {
        relativeFormatter.string(from: date)
    }

    static func bytes(_ count: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: count, countStyle: .file)
    }
}

// MARK: - View controller helpers

extension UIViewController {
    /// Presents a simple single-action alert.
    func asp_showAlert(title: String, message: String, action: String = "OK", completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: action, style: .default) { _ in completion?() })
        present(alert, animated: true)
    }

    /// Presents a destructive confirm/cancel alert.
    func asp_showConfirm(title: String, message: String, confirmTitle: String = "Delete", onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: confirmTitle, style: .destructive) { _ in onConfirm() })
        present(alert, animated: true)
    }
}

// MARK: - String validation

extension String {
    var asp_trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var asp_isValidEmail: Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return range(of: pattern, options: .regularExpression) != nil
    }
}
