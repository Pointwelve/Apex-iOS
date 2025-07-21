//
//  ContentView.swift
//  Apex
//
//  Created by Ryne Cheow on 21/7/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showLanguageSelection = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)

                Text(.helloWorld)
                    .font(.title2)

                Text(.appTagline)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                Button {
                    showLanguageSelection = true
                } label: {
                    HStack {
                        Image(systemName: "globe")
                        Text(.settings)
                    }
                    .padding()
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle(Text(.appName))
            .sheet(isPresented: $showLanguageSelection) {
                LanguageSelectionView()
            }
        }
        .withLocalization()
    }
}

#Preview {
    ContentView()
}
