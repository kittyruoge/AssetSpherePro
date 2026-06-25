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

    /// The scroll view created by `asp_makeScrollingStack`, if any. Tracked so
    /// the keyboard observers can adjust its insets to keep fields visible.
    private weak var asp_managedScrollView: UIScrollView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ASPTheme.Color.backgroundBottom
        asp_setupBackground()
        asp_setupDismissKeyboardGesture()
        asp_observeKeyboard()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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

    // MARK: - Keyboard avoidance

    /// Observes keyboard frame changes so the managed scroll view can inset its
    /// content and reveal the focused field instead of leaving it hidden behind
    /// the keyboard.
    private func asp_observeKeyboard() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(asp_keyboardWillChange(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(asp_keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func asp_keyboardWillChange(_ note: Notification) {
        guard let scrollView = asp_managedScrollView,
              let frameValue = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        // Convert the keyboard frame into this view's coordinate space and
        // measure how much of the scroll view it covers.
        let keyboardFrame = view.convert(frameValue.cgRectValue, from: nil)
        let overlap = max(0, scrollView.frame.maxY - keyboardFrame.minY)

        var insets = scrollView.contentInset
        insets.bottom = overlap
        scrollView.contentInset = insets
        scrollView.verticalScrollIndicatorInsets.bottom = overlap

        asp_scrollFirstResponderToVisible(in: scrollView)
    }

    @objc private func asp_keyboardWillHide(_ note: Notification) {
        guard let scrollView = asp_managedScrollView else { return }
        var insets = scrollView.contentInset
        insets.bottom = 0
        scrollView.contentInset = insets
        scrollView.verticalScrollIndicatorInsets.bottom = 0

        // Return the content to its resting position so the interface moves
        // back down instead of staying scrolled up after the keyboard leaves.
        let resting = CGPoint(x: 0, y: -scrollView.adjustedContentInset.top)
        scrollView.setContentOffset(resting, animated: true)
    }

    /// Reveals the focused field when the keyboard appears. The target rect is
    /// extended from the field down to the bottom of the content, so the action
    /// button below it is lifted above the keyboard too rather than pushed
    /// behind it. Deferred to the next run loop so the freshly-applied bottom
    /// inset is in effect first.
    private func asp_scrollFirstResponderToVisible(in scrollView: UIScrollView) {
        DispatchQueue.main.async {
            guard let responder = self.asp_findFirstResponder(in: scrollView) else { return }
            let fieldFrame = responder.convert(responder.bounds, to: scrollView)

            // Span from the top of the focused field to the bottom of all
            // content, so scrollRectToVisible lifts the whole lower section
            // (including the submit button) clear of the keyboard.
            let contentBottom = scrollView.contentSize.height
            let top = fieldFrame.minY - 24
            let target = CGRect(x: 0, y: top, width: 1, height: contentBottom - top)
            scrollView.scrollRectToVisible(target, animated: true)
        }
    }

    private func asp_findFirstResponder(in view: UIView) -> UIView? {
        if view.isFirstResponder { return view }
        for subview in view.subviews {
            if let found = asp_findFirstResponder(in: subview) { return found }
        }
        return nil
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
        asp_managedScrollView = scrollView

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
