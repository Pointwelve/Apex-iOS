//
//  PersonalizationView.swift
//  Apex
//
//  Created by Claude on 2025-07-21.
//

import SwiftUI

struct PersonalizationView: View {
    @State private var selectedAge: Int = 23
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @Environment(\.colorScheme) private var colorScheme

    private let minAge = 18
    private let maxAge = 80
    private let itemSpacing: CGFloat = 20
    private let itemWidth: CGFloat = 60

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with back button
                HStack {
                    Button(action: {}, label: {
                        Circle()
                            .fill(.blue)
                            .frame(width: 44, height: 44)
                            .overlay {
                                Image(systemName: "arrow.left")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 18, weight: .medium))
                            }
                    })
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)

                // Title
                Text("Personalization")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(primaryTextColor)
                    .padding(.top, 32)

                Spacer()

                // Question section
                VStack(spacing: 16) {
                    Text("What's your age?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(primaryTextColor)

                    Text("Help us create a personalized fitness journey\n" +
                         "that's perfectly tailored to your body and goals.")
                        .font(.system(size: 16))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)

                Spacer()

                // Age selection area
                VStack(spacing: 24) {
                    // Large age display
                    Text("\(selectedAge)")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundStyle(.blue)

                    // Triangle pointing down
                    Image(systemName: "triangle.fill")
                        .foregroundStyle(.green)
                        .font(.system(size: 12))
                        .rotationEffect(.degrees(180))
                        .offset(y: 5)

                    // Age picker with drag gesture
                    AgePickerView(
                        selectedAge: $selectedAge,
                        minAge: minAge,
                        maxAge: maxAge,
                        itemWidth: itemWidth,
                        itemSpacing: itemSpacing,
                        colorScheme: colorScheme
                    )
                }
                .padding(.vertical, 40)

                Spacer()

                // Continue button
                Button(action: {}, label: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.blue)
                        .frame(height: 56)
                        .overlay {
                            Text("Continue")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                })
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .background(backgroundColor.ignoresSafeArea())
        }
        .navigationBarHidden(true)
    }

    private var primaryTextColor: Color {
        colorScheme == .dark ? .white : .black
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? .black : .white
    }
}

struct AgePickerView: View {
    @Binding var selectedAge: Int
    let minAge: Int
    let maxAge: Int
    let itemWidth: CGFloat
    let itemSpacing: CGFloat
    let colorScheme: ColorScheme

    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    private var totalItemWidth: CGFloat {
        itemWidth + itemSpacing
    }

    private func offsetForAge(_ age: Int) -> CGFloat {
        return -CGFloat(age - minAge) * totalItemWidth
    }

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let centerX = screenWidth / 2

            HStack(spacing: itemSpacing) {
                ForEach(minAge...maxAge, id: \.self) { age in
                    Button(action: {
                        selectAge(age)
                    }, label: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(age == selectedAge ? .blue : .clear)
                            .frame(width: itemWidth, height: itemWidth)
                            .overlay {
                                Text("\(age)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(textColor(for: age))
                            }
                    })
                }
            }
            .offset(x: centerX - itemWidth/2 + offsetForAge(selectedAge) + dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        dragOffset = value.translation.width
                        updateSelectedAge(for: value.translation.width)
                    }
                    .onEnded { value in
                        isDragging = false
                        snapToNearestAge(velocity: value.velocity.width)
                        dragOffset = 0
                    }
            )
        }
        .frame(height: itemWidth)
        .clipped()
    }

    private func textColor(for age: Int) -> Color {
        age == selectedAge ? .white : (colorScheme == .dark ? .gray : .gray)
    }

    private func selectAge(_ age: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedAge = age
        }
    }

    private func updateSelectedAge(for dragTranslation: CGFloat) {
        // Calculate which age should be centered based on drag translation
        let offset = dragTranslation / totalItemWidth
        let targetAgeIndex = Int(round(-offset))
        let newAgeIndex = selectedAge - minAge + targetAgeIndex
        let clampedIndex = max(0, min(maxAge - minAge, newAgeIndex))
        let newAge = minAge + clampedIndex

        if newAge != selectedAge && isDragging {
            selectedAge = newAge
        }
    }

    private func snapToNearestAge(velocity: CGFloat) {
        // Calculate momentum effect
        let momentum = velocity * 0.001 // Reduced momentum for better control
        let finalOffset = dragOffset + momentum

        // Calculate which age we should snap to
        let ageOffset = finalOffset / totalItemWidth
        let targetAgeIndex = Int(round(-ageOffset))
        let newAgeIndex = selectedAge - minAge + targetAgeIndex
        let clampedIndex = max(0, min(maxAge - minAge, newAgeIndex))
        let finalAge = minAge + clampedIndex

        withAnimation(.easeOut(duration: 0.4)) {
            selectedAge = finalAge
        }
    }
}

#Preview("Light Mode") {
    PersonalizationView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    PersonalizationView()
        .preferredColorScheme(.dark)
}
