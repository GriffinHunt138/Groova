//
//  Auth.swift
//  Groova
//
//  Sign in and the account it unlocks. The backend isn't built yet, so `MockAuthBackend`
//  stands in for it: it keeps accounts in UserDefaults on this device and gives each provider
//  a stable fake user id, so signing out and back in finds the same account.
//  Swap in a real `AuthBackend` later without touching the screens.
//

import Foundation
import Observation

nonisolated enum AuthProvider: String, Codable, Sendable {
    case apple, google

    var name: String { self == .apple ? "Apple" : "Google" }
}

/// How much producing someone has done, as they told us in onboarding.
nonisolated enum ProducerLevel: String, Codable, CaseIterable, Identifiable, Sendable {
    case newcomer, tinkerer, builder, releasing

    var id: String { rawValue }

    var title: String {
        switch self {
        case .newcomer: "Brand new"
        case .tinkerer: "I've messed around"
        case .builder: "I've finished tracks"
        case .releasing: "I release music"
        }
    }

    var detail: String {
        switch self {
        case .newcomer: "Never made a beat, or only just started"
        case .tinkerer: "Made a few loops, never finished one"
        case .builder: "I can take an idea to a full track"
        case .releasing: "My music is out there"
        }
    }

    var symbol: String {
        switch self {
        case .newcomer: "sparkles"
        case .tinkerer: "slider.horizontal.3"
        case .builder: "waveform"
        case .releasing: "opticaldisc.fill"
        }
    }

    /// The badge name shown on the result screen and in Profile.
    var rank: String {
        switch self {
        case .newcomer: "Fresh Ears"
        case .tinkerer: "Loop Maker"
        case .builder: "Track Builder"
        case .releasing: "Studio Pro"
        }
    }

    /// The most Foundations units the placement check can skip for this level.
    var maxPlacement: Int {
        switch self {
        case .newcomer: 0
        case .tinkerer: 3
        case .builder, .releasing: 6
        }
    }
}

/// What the backend keeps about a person once onboarding is done.
nonisolated struct Account: Codable, Sendable, Equatable {
    var userID: String
    var provider: AuthProvider
    var displayName: String
    var email: String?
    var level: ProducerLevel
    var genre: Genre
    /// Foundations units skipped by the placement check (0 to 6).
    var placedUnits: Int
    var dailyGoal: Int
    var createdAt: Date
    /// The in-app intro tour has been shown.
    var seenGuide = false
    /// Making music or understanding it, from onboarding.
    var purpose: LearnerGoal? = nil
    /// Onboarding diagnostic answers: question id to option id.
    var diagnosis: [String: String]? = nil
}

nonisolated struct AuthSession: Codable, Sendable, Equatable {
    var userID: String
    var provider: AuthProvider
    var displayName: String
    var email: String?
}

nonisolated enum AuthError: Error {
    case cancelled, failed(String)
}

/// The seam the real backend plugs into.
protocol AuthBackend {
    /// Signs in with the provider. Returns the session and the account if one already exists.
    func signIn(with provider: AuthProvider) async throws -> (AuthSession, Account?)
    func save(_ account: Account) async throws
    func deleteAccount(_ userID: String) async throws
}

/// Device-only stand-in until the backend exists.
struct MockAuthBackend: AuthBackend {
    private static let accountsKey = "groova.mock.accounts.v1"

    func signIn(with provider: AuthProvider) async throws -> (AuthSession, Account?) {
        try await Task.sleep(for: .milliseconds(700)) // feel like a network call
        let defaults = UserDefaults.standard
        let idKey = "groova.mock.uid.\(provider.rawValue)"
        let uid = defaults.string(forKey: idKey) ?? {
            let new = "\(provider.rawValue)-\(UUID().uuidString.prefix(8).lowercased())"
            defaults.set(new, forKey: idKey)
            return new
        }()
        let session = AuthSession(userID: uid, provider: provider, displayName: "", email: nil)
        return (session, Self.accounts()[uid])
    }

    func save(_ account: Account) async throws {
        var all = Self.accounts()
        all[account.userID] = account
        if let data = try? JSONEncoder().encode(all) { UserDefaults.standard.set(data, forKey: Self.accountsKey) }
    }

    func deleteAccount(_ userID: String) async throws {
        var all = Self.accounts()
        all[userID] = nil
        if let data = try? JSONEncoder().encode(all) { UserDefaults.standard.set(data, forKey: Self.accountsKey) }
    }

    private static func accounts() -> [String: Account] {
        guard let data = UserDefaults.standard.data(forKey: accountsKey),
              let all = try? JSONDecoder().decode([String: Account].self, from: data) else { return [:] }
        return all
    }
}

@Observable
final class AuthStore {
    /// Signed in. With no account yet, onboarding runs.
    private(set) var session: AuthSession?
    /// Signed in and onboarded.
    private(set) var account: Account?
    private(set) var signingIn: AuthProvider?
    var errorMessage: String?

    private let backend: AuthBackend
    private let sessionKey = "groova.session.v1"

    init(backend: AuthBackend = MockAuthBackend()) {
        self.backend = backend
        if let data = UserDefaults.standard.data(forKey: sessionKey),
           let saved = try? JSONDecoder().decode(Stored.self, from: data) {
            session = saved.session
            account = saved.account
        }
    }

    nonisolated private struct Stored: Codable {
        var session: AuthSession
        var account: Account?
    }

    private func persist() {
        if let session, let data = try? JSONEncoder().encode(Stored(session: session, account: account)) {
            UserDefaults.standard.set(data, forKey: sessionKey)
        } else {
            UserDefaults.standard.removeObject(forKey: sessionKey)
        }
    }

    var needsOnboarding: Bool { session != nil && account == nil }

    func signIn(with provider: AuthProvider) async {
        guard signingIn == nil else { return }
        signingIn = provider
        errorMessage = nil
        defer { signingIn = nil }
        do {
            let (s, a) = try await backend.signIn(with: provider)
            session = s
            account = a
            persist()
        } catch AuthError.cancelled {
            // The person backed out of the sheet. Nothing to say.
        } catch {
            errorMessage = "Couldn't sign in with \(provider.name). Try again."
        }
    }

    /// Onboarding is done: create the account.
    func finishOnboarding(_ new: Account) async {
        account = new
        persist()
        try? await backend.save(new)
    }

    func markGuideSeen() {
        guard var a = account, !a.seenGuide else { return }
        a.seenGuide = true
        account = a
        persist()
        Task { try? await backend.save(a) }
    }

    func signOut() {
        session = nil
        account = nil
        persist()
    }

    /// Wipes the account too, so the next sign in starts onboarding again.
    func deleteAccount() async {
        if let id = session?.userID { try? await backend.deleteAccount(id) }
        signOut()
    }
}
