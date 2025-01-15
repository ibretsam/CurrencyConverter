//
//  CurrencyCard.swift
//  CurrencyConverter
//
//  Created by MasterBi on 14/01/2025.
//
import SwiftUI

/// A view that displays an animated currency card with interactive elements.
///
/// # Overview
/// The currency card provides a visually appealing way to display currency amounts with:
/// - Animated digit transitions
/// - Interactive currency selection
/// - Responsive layout adaptation
/// - Visual depth through shadows
///
/// # Components
/// - Header: Currency selector with From/To indicator
/// - Content: Animated amount display with currency code
///
/// # Usage Example
/// ```swift
/// CurrencyCard(
///     currency: .USD,
///     amount: "123.45",
///     isSource: true,
///     onHeaderTap: { /* Handle currency selection */ }
/// )
/// ```
///
/// # Layout Structure
/// ```
/// ┌──────────────────────────────────────────────────────────┐
/// │                                                          │
/// │  From ◇ United States Dollar                             │
/// │                                                          │
/// │                                       123.456.789  USD   │
/// │                                                          │
/// └──────────────────────────────────────────────────────────┘
/// ```
struct CurrencyCard: View {
    /// The currency to display and use for conversion
    let currency: Currency
    
    /// The amount to display, formatted as a string
    let amount: String
    
    /// Indicates if this is a source (From) or destination (To) currency card
    let isSource: Bool
    
    /// Callback triggered when the currency selector header is tapped
    let onHeaderTap: () -> Void
    
    // MARK: - Private Helpers
    
    /// Creates an animated text display for the currency amount
    /// - Parameter text: The amount to display
    /// - Returns: A view containing animated digits with proper scaling
    private func amountText(_ text: String) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(text.enumerated()), id: \.offset) { index, digit in
                AnimatedDigitView(digit: digit, isNew: index == text.count - 1)
            }
        }
        .scaleEffect(max(0.8, 1 - CGFloat(text.count) * 0.04))
        .minimumScaleFactor(0.3)
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    // MARK: - Body Implementation
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Currency selector header
            Button(action: onHeaderTap) {
                HStack {
                    Text(isSource ? "From" : "To")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    Text(currency.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
            .frame(height: 32)
            .padding(.bottom, 8)
            
            // Animated amount display
            HStack(alignment: .firstTextBaseline) {
                amountText(amount)
                Text(currency.rawValue)
                    .font(.callout)
                    .fontWeight(.semibold)
            }
            .frame(height: 60, alignment: .center)
        }
        .frame(height: 130)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

/// A view that displays a single digit with animation effects when it changes
///
/// # Features
/// - Blur transition effect
/// - Scale animation
/// - Offset animation for new digits
struct AnimatedDigitView: View {
    /// The digit character to display
    let digit: Character
    
    /// Indicates if this is a newly added digit
    let isNew: Bool
    
    var body: some View {
        Text(String(digit))
            .font(.system(size: 80, weight: .semibold, design: .monospaced))
            .transition(
                .blurReplace
                    .combined(with: .scale)
                    .combined(with: .offset(x: isNew ? -32 : 0, y: 12))
            )
            .id(UUID())
    }
}

// MARK: - Custom Transitions

extension AnyTransition {
    /// A custom transition that combines blur and fade effects
    static var blurReplace: AnyTransition {
        .modifier(
            active: BlurModifier(blur: 20),
            identity: BlurModifier(blur: 0)
        )
    }
}

/// A view modifier that applies a gaussian blur effect
struct BlurModifier: ViewModifier {
    /// The intensity of the blur effect
    let blur: CGFloat
    
    func body(content: Content) -> some View {
        content.blur(radius: blur)
    }
}
