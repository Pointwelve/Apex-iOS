//
//  ContentView.swift
//  Apex
//
//  Created by Ryne Cheow on 21/7/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showLanguageSelection = false
    @StateObject private var localizationManager = LocalizationManager.shared

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HeaderView()

                Spacer()

                SettingsButton {
                    showLanguageSelection = true
                }
            }
            .padding()
            .navigationTitle(Text(.appName))
            .sheet(isPresented: $showLanguageSelection) {
                LanguageSelectionView()
            }
        }
        .withLocalization()
        .task {
            // Preload localization strings for better performance
            localizationManager.preloadCommonStrings()
        }
    }
}

// MARK: - Subviews for better performance and reusability
private struct HeaderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .accessibilityLabel("App icon")

            Text(.helloWorld)
                .font(.title2)
                .multilineTextAlignment(.center)

            Text(.appTagline)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

private struct SettingsButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "globe")
                Text(.settings)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.accentColor.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Language settings")
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    ContentView()
        .preferredColorScheme(.dark)
}
