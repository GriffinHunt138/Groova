//
//  AuthView.swift
//  Groova
//
//  The first screen: sign in or create an account with Apple or Google. Both are the same
//  step. A new account goes on to onboarding, an existing one goes straight into the app.
//

import Foundation
import SwiftUI

struct AuthView: View {
    @Environment(AuthStore.self) private var auth
    @State private var animate = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()
                WooferView(mood: .party, size: 170, bouncing: true)
                HStack(alignment: .center, spacing: 5) {
                    ForEach(0..<9, id: \.self) { i in
                        Capsule()
                            .fill(Theme.brand)
                            .frame(width: 10, height: animate ? CGFloat([32, 55, 24, 64, 42, 59, 28, 49, 21][i]) : 14)
                            .animation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true).delay(Double(i) * 0.08),
                                       value: animate)
                    }
                }
                .frame(height: 70)
                .padding(.top, 18)
                Text("groova")
                    .font(.display(56, weight: .black))
                    .foregroundStyle(Theme.brand)
                    .padding(.top, 18)
                Text("Learn music production\nby making music.")
                    .font(.label(19, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.top, 8)
                Spacer()
                VStack(spacing: 12) {
                    if let error = auth.errorMessage {
                        Text(error)
                            .font(.label(14, weight: .bold))
                            .foregroundStyle(Theme.missInk)
                            .transition(.opacity)
                    }
                    ProviderButton(provider: .apple, busy: auth.signingIn == .apple, disabled: auth.signingIn != nil) {
                        signIn(.apple)
                    }
                    ProviderButton(provider: .google, busy: auth.signingIn == .google, disabled: auth.signingIn != nil) {
                        signIn(.google)
                    }
                    Text("New here? Same buttons. Woofer will set you up.")
                        .font(.label(14, weight: .semibold))
                        .foregroundStyle(Theme.textSecondary)
                        .padding(.top, 4)
                    Text("By continuing you agree to the Terms and Privacy Policy.")
                        .font(.label(12, weight: .medium))
                        .foregroundStyle(Theme.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .animation(.easeInOut(duration: 0.2), value: auth.errorMessage)
            }
        }
        .onAppear { animate = true }
    }

    private func signIn(_ provider: AuthProvider) {
        Haptics.thump()
        Task { await auth.signIn(with: provider) }
    }
}

/// "Continue with Apple / Google". Apple's is black with the Apple logo, as Apple's
/// guidelines ask. Google's is white with a border; swap the placeholder "G" for Google's
/// official logo asset when the real sign in goes in.
private struct ProviderButton: View {
    let provider: AuthProvider
    let busy: Bool
    let disabled: Bool
    let action: () -> Void

    private var apple: Bool { provider == .apple }
    private var shape: RoundedRectangle { RoundedRectangle(cornerRadius: 16, style: .continuous) }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if busy {
                    ProgressView().tint(apple ? .white : Theme.text)
                } else if apple {
                    Image(systemName: "apple.logo").font(.system(size: 20, weight: .semibold))
                } else {
                    GoogleMark().frame(width: 20, height: 20)
                }
                Text("Continue with \(provider.name)")
                    .font(.label(17, weight: .heavy))
            }
            .foregroundStyle(apple ? Color.white : Theme.text)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(shape.fill(apple ? Color.black : Theme.surface))
            .overlay(shape.strokeBorder(apple ? Color.clear : Theme.stroke, lineWidth: Theme.border))
            .background(shape.fill(apple ? Color(hex: 0x3A3A3C) : Theme.stroke).offset(y: 4))
            .padding(.bottom, 4)
        }
        .buttonStyle(PressScaleStyle(scale: 0.98))
        .disabled(disabled)
        .opacity(disabled && !busy ? 0.5 : 1)
        .accessibilityLabel("Continue with \(provider.name)")
    }
}

/// Placeholder for Google's logo until the official asset is added.
private struct GoogleMark: View {
    var body: some View {
        Text("G")
            .font(.system(size: 20, weight: .black, design: .rounded))
            .foregroundStyle(
                AngularGradient(colors: [Color(hex: 0x4285F4), Color(hex: 0x34A853), Color(hex: 0xFBBC05),
                                         Color(hex: 0xEA4335), Color(hex: 0x4285F4)],
                                center: .center)
            )
    }
}

#Preview {
    AuthView().environment(AuthStore())
}
