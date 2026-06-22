//
//  ASPUserManager.swift
//  AssetSpherePro
//
//  Local account system: register, login, logout, session persistence.
//  Passwords are stored in the Keychain; the user record lives in Core Data.
//  No network, no server.
//

import CoreData

final class ASPUserManager {

    static let shared = ASPUserManager()

    private init() {}

    private var stack: ASPCoreDataStack { .shared }
    private var entity: String { ASPCoreDataStack.Entity.user }

    // MARK: - Session keys

    private enum Keys {
        static let loggedInUserId = "asp_logged_in_user_id"
        static let rememberMe = "asp_remember_me"
        static let seededUserIds = "asp_seeded_user_ids"
    }

    // MARK: - Built-in review account

    static let reviewEmail = "zz123"
    static let reviewPassword = "abc123"
    static let reviewUsername = "App Reviewer"

    // MARK: - Session state

    private(set) var currentUser: ASPUserModel?

    /// True when the current session is an unauthenticated guest session.
    private(set) var isGuest: Bool = false

    var asp_isLoggedIn: Bool { currentUser != nil }

    // MARK: - Guest mode

    /// Starts an in-memory guest session. Nothing is persisted to Core Data or
    /// the Keychain; the guest can explore the app and create local content,
    /// but the account itself is not saved. Used by the "Continue as Guest"
    /// entry point on the login screen.
    func asp_continueAsGuest() {
        currentUser = ASPUserModel(username: "Guest", email: "")
        isGuest = true
    }

    /// Restores a session at launch if a user was remembered. Returns true if a
    /// user is now logged in.
    @discardableResult
    func asp_restoreSession() -> Bool {
        asp_ensureReviewAccountExists()
        guard UserDefaults.standard.bool(forKey: Keys.rememberMe),
              let id = UserDefaults.standard.string(forKey: Keys.loggedInUserId),
              let user = object(forId: id) else {
            return false
        }
        currentUser = Self.map(user)
        return true
    }

    // MARK: - Register

    enum RegisterResult {
        case success
        case emailTaken
        case invalid(String)
    }

    func asp_register(username: String, email: String, password: String) -> RegisterResult {
        let user = username.asp_trimmed
        let mail = email.asp_trimmed.lowercased()

        guard !user.isEmpty else { return .invalid("Please enter a username.") }
        guard mail.asp_isValidEmail else { return .invalid("Please enter a valid email address.") }
        guard password.count >= 6 else { return .invalid("Password must be at least 6 characters.") }
        guard object(forEmail: mail) == nil else { return .emailTaken }

        let object = stack.insert(entity)
        let id = UUID().uuidString
        object.setValue(id, forKey: "userId")
        object.setValue(user, forKey: "username")
        object.setValue(mail, forKey: "email")
        object.setValue(nil, forKey: "avatar")
        object.setValue(Date(), forKey: "registerDate")
        object.setValue(nil, forKey: "lastLoginDate")
        stack.save()

        ASPKeychainManager.shared.asp_savePassword(password, account: mail)
        return .success
    }

    // MARK: - Login

    enum LoginResult {
        case success
        case wrongCredentials
        case invalid(String)
    }

    func asp_login(email: String, password: String, rememberMe: Bool) -> LoginResult {
        let mail = email.asp_trimmed.lowercased()
        // The built-in review account uses a short identifier, not an email,
        // so it is allowed to skip the email-format check.
        let isReviewAccount = (mail == Self.reviewEmail.lowercased())
        guard isReviewAccount || mail.asp_isValidEmail else {
            return .invalid("Please enter a valid email address.")
        }
        guard !password.isEmpty else { return .invalid("Please enter your password.") }

        asp_ensureReviewAccountExists()

        guard let object = object(forEmail: mail) else { return .wrongCredentials }
        guard ASPKeychainManager.shared.asp_verifyPassword(password, account: mail) else {
            return .wrongCredentials
        }

        object.setValue(Date(), forKey: "lastLoginDate")
        stack.save()

        let model = Self.map(object)
        currentUser = model
        isGuest = false

        UserDefaults.standard.set(model.userId, forKey: Keys.loggedInUserId)
        UserDefaults.standard.set(rememberMe, forKey: Keys.rememberMe)

        // Seed demo data the first time a given account signs in.
        asp_seedDemoDataIfNeeded(for: model)

        ASPActivityManager.shared.asp_record(type: .login, title: model.username)
        return .success
    }

    // MARK: - Logout

    func asp_logout() {
        currentUser = nil
        isGuest = false
        UserDefaults.standard.removeObject(forKey: Keys.loggedInUserId)
        UserDefaults.standard.set(false, forKey: Keys.rememberMe)
    }

    // MARK: - Password reset (local simulation)

    enum ResetResult {
        case success
        case notFound
        case invalid(String)
    }

    /// Locally resets a password — no email is sent. Validates the account
    /// exists, then overwrites the stored Keychain password.
    func asp_resetPassword(email: String, newPassword: String) -> ResetResult {
        let mail = email.asp_trimmed.lowercased()
        guard mail.asp_isValidEmail else { return .invalid("Please enter a valid email address.") }
        guard newPassword.count >= 6 else { return .invalid("Password must be at least 6 characters.") }
        guard object(forEmail: mail) != nil else { return .notFound }

        ASPKeychainManager.shared.asp_savePassword(newPassword, account: mail)
        return .success
    }

    // MARK: - Profile updates

    func asp_updateAvatar(_ avatarPath: String?) {
        guard let id = currentUser?.userId, let object = object(forId: id) else { return }
        object.setValue(avatarPath, forKey: "avatar")
        stack.save()
        currentUser?.avatar = avatarPath
    }

    func asp_updateUsername(_ username: String) {
        let name = username.asp_trimmed
        guard !name.isEmpty, let id = currentUser?.userId, let object = object(forId: id) else { return }
        object.setValue(name, forKey: "username")
        stack.save()
        currentUser?.username = name
    }

    // MARK: - Review account bootstrap

    /// Ensures the fixed review account exists so app-review can always sign in.
    func asp_ensureReviewAccountExists() {
        guard object(forEmail: Self.reviewEmail) == nil else { return }
        let object = stack.insert(entity)
        object.setValue(UUID().uuidString, forKey: "userId")
        object.setValue(Self.reviewUsername, forKey: "username")
        object.setValue(Self.reviewEmail, forKey: "email")
        object.setValue(nil, forKey: "avatar")
        object.setValue(Date(), forKey: "registerDate")
        object.setValue(nil, forKey: "lastLoginDate")
        stack.save()
        ASPKeychainManager.shared.asp_savePassword(Self.reviewPassword, account: Self.reviewEmail)
    }

    // MARK: - Demo data seeding

    private func asp_seedDemoDataIfNeeded(for user: ASPUserModel) {
        var seeded = Set(UserDefaults.standard.stringArray(forKey: Keys.seededUserIds) ?? [])
        guard !seeded.contains(user.userId) else { return }

        ASPDemoData.seed()

        seeded.insert(user.userId)
        UserDefaults.standard.set(Array(seeded), forKey: Keys.seededUserIds)
    }

    // MARK: - Lookups & mapping

    private func object(forId id: String) -> NSManagedObject? {
        stack.fetch(entity, predicate: NSPredicate(format: "userId == %@", id), limit: 1).first
    }

    private func object(forEmail email: String) -> NSManagedObject? {
        stack.fetch(entity, predicate: NSPredicate(format: "email ==[c] %@", email), limit: 1).first
    }

    private static func map(_ object: NSManagedObject) -> ASPUserModel {
        ASPUserModel(
            userId: object.value(forKey: "userId") as? String ?? UUID().uuidString,
            username: object.value(forKey: "username") as? String ?? "",
            email: object.value(forKey: "email") as? String ?? "",
            avatar: object.value(forKey: "avatar") as? String,
            registerDate: object.value(forKey: "registerDate") as? Date ?? Date(),
            lastLoginDate: object.value(forKey: "lastLoginDate") as? Date
        )
    }
}
