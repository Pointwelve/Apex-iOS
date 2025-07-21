//
//  PerformanceMonitor.swift
//  Apex
//
//  Created by Ryne Cheow on 21/7/25.
//

import Foundation
import SwiftUI
import Combine

/// Simple performance monitoring system for the app
@MainActor
final class PerformanceMonitor: ObservableObject {
    static let shared = PerformanceMonitor()

    @Published private(set) var metrics: PerformanceMetrics = PerformanceMetrics()

    private var startTimes: [String: Date] = [:]

    private init() {}

    /// Start timing an operation
    func startTiming(_ operation: String) {
        startTimes[operation] = Date()
    }

    /// End timing an operation and record the duration
    func endTiming(_ operation: String) {
        guard let startTime = startTimes.removeValue(forKey: operation) else {
            return
        }

        let duration = Date().timeIntervalSince(startTime)
        recordMetric(operation: operation, duration: duration)
    }

    private func recordMetric(operation: String, duration: TimeInterval) {
        switch operation {
        case "localization":
            metrics.localizationLoadTime = duration
        case "view_render":
            metrics.viewRenderTime = duration
        case "language_change":
            metrics.languageChangeTime = duration
        case "app_launch":
            metrics.appLaunchTime = duration
        default:
            metrics.customMetrics[operation] = duration
        }

        // Log performance issues
        if duration > 0.1 {
            print("⚠️ Performance Warning: \(operation) took \(String(format: "%.3f", duration))s")
        }
    }
}

// MARK: - Performance Metrics
struct PerformanceMetrics {
    var appLaunchTime: TimeInterval = 0
    var localizationLoadTime: TimeInterval = 0
    var viewRenderTime: TimeInterval = 0
    var languageChangeTime: TimeInterval = 0
    var customMetrics: [String: TimeInterval] = [:]

    var averageMetrics: [String: TimeInterval] {
        var averages: [String: TimeInterval] = [:]

        if appLaunchTime > 0 { averages["App Launch"] = appLaunchTime }
        if localizationLoadTime > 0 { averages["Localization"] = localizationLoadTime }
        if viewRenderTime > 0 { averages["View Render"] = viewRenderTime }
        if languageChangeTime > 0 { averages["Language Change"] = languageChangeTime }

        return averages.merging(customMetrics) { $1 }
    }
}

// MARK: - Performance View Modifier
struct PerformanceTracker: ViewModifier {
    let operation: String
    @StateObject private var monitor = PerformanceMonitor.shared

    func body(content: Content) -> some View {
        content
            .onAppear {
                monitor.startTiming(operation)
            }
            .onDisappear {
                monitor.endTiming(operation)
            }
    }
}

extension View {
    /// Track performance of view rendering
    func trackPerformance(_ operation: String = "view_render") -> some View {
        modifier(PerformanceTracker(operation: operation))
    }
}

// MARK: - Performance Debug View
struct PerformanceDebugView: View {
    @StateObject private var monitor = PerformanceMonitor.shared

    var body: some View {
        NavigationView {
            List {
                if monitor.metrics.averageMetrics.isEmpty {
                    Text("No performance data yet")
                        .foregroundColor(.secondary)
                } else {
                    Section("Performance Metrics") {
                        ForEach(Array(monitor.metrics.averageMetrics.keys.sorted()), id: \.self) { key in
                            HStack {
                                Text(key)
                                Spacer()
                                Text("\(String(format: "%.3f", monitor.metrics.averageMetrics[key] ?? 0))s")
                                    .foregroundColor(getColorForDuration(monitor.metrics.averageMetrics[key] ?? 0))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Performance")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func getColorForDuration(_ duration: TimeInterval) -> Color {
        if duration > 0.1 {
            return .red
        } else if duration > 0.05 {
            return .orange
        } else {
            return .green
        }
    }
}
