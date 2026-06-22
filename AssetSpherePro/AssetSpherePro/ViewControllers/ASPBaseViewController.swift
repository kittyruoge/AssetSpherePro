//
//  ASPBaseViewController.swift
//  AssetSpherePro
//
//  Base class providing the shared gradient background, decorative blurred
//  accent blobs, and a scrollable content container used by most screens.
//

import UIKit

class ASPBaseViewController: UIViewController {

    /// Background gradient filling the whole screen.
    private let backgroundView = ASPGradientView(colors: ASPTheme.Gradient.background)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ASPTheme.Color.backgroundBottom
        asp_setupBackground()
        asp_setupDismissKeyboardGesture()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Keyboard dismissal

    /// Adds a tap recognizer that dismisses the keyboard when the user taps
    /// outside a text field. `cancelsTouchesInView = false` keeps buttons,
    /// list cards, and other controls fully tappable.
    private func asp_setupDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(asp_dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func asp_dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Background

    private func asp_setupBackground() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(backgroundView, at: 0)
        backgroundView.asp_pinEdges(to: view)

        // Decorative soft accent blobs for depth.
        asp_addBlob(color: ASPTheme.Color.accent.withAlphaComponent(0.5),
                    center: CGPoint(x: 0.85, y: 0.08), diameter: 280)
        asp_addBlob(color: ASPTheme.Color.accentSecondary.withAlphaComponent(0.35),
                    center: CGPoint(x: 0.1, y: 0.9), diameter: 320)
    }

    private func asp_addBlob(color: UIColor, center: CGPoint, diameter: CGFloat) {
        let blob = UIView()
        blob.translatesAutoresizingMaskIntoConstraints = false
        blob.backgroundColor = color
        blob.layer.cornerRadius = diameter / 2
        view.insertSubview(blob, aboveSubview: backgroundView)

        // Soften with a blur overlay on top of the whole background stack.
        NSLayoutConstraint.activate([
            blob.widthAnchor.constraint(equalToConstant: diameter),
            blob.heightAnchor.constraint(equalToConstant: diameter),
            blob.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            blob.centerYAnchor.constraint(equalTo: view.topAnchor, constant: 0)
        ])
        // Position via transform after layout using multipliers on the frame.
        blob.layer.zPosition = -1
        DispatchQueue.main.async {
            blob.center = CGPoint(x: self.view.bounds.width * center.x,
                                  y: self.view.bounds.height * center.y)
        }

        // Blur veil over the blobs so they read as soft glows, not hard circles.
        let veil = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        veil.translatesAutoresizingMaskIntoConstraints = false
        veil.alpha = 0.6
        view.insertSubview(veil, aboveSubview: blob)
        veil.asp_pinEdges(to: view)
    }

    // MARK: - Scrolling container helper

    /// Creates and installs a vertical scroll view with a content stack.
    /// Returns the content stack for callers to add arranged subviews.
    func asp_makeScrollingStack(topInset: CGFloat = 8, spacing: CGFloat = ASPTheme.Layout.cardSpacing) -> UIStackView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .always
        view.addSubview(scrollView)

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = spacing
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: topInset),
            stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor,
                                           constant: ASPTheme.Layout.screenInset),
            stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor,
                                            constant: -ASPTheme.Layout.screenInset),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32)
        ])
        return stack
    }
}
