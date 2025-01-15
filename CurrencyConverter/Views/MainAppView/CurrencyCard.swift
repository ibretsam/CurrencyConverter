//
//  CurrencyCard.swift
//  CurrencyConverter
//
//  Created by MasterBi on 14/01/2025.
//
import SwiftUI

struct CurrencyCard: View {
/// A view that displays a currency card with an animated amount display.
///
/// The currency card consists of two main parts:
/// - A header showing the currency type (From/To) with a selector
/// - An animated amount display with the currency code
///
/// Example usage:
/// ```swift
/// CurrencyCard(
///     currency: .USD,
///     amount: "123.45",
///     isSource: true,
///     onHeaderTap: { /* Handle header tap */ }
/// )
/// ```
/// - Parameters:
///   - currency: The currency to display, conforming to the `Currency` type
///   - amount: The string representation of the amount to display
///   - isSource: A boolean indicating whether this is a source (From) or destination (To) currency
///   - onHeaderTap: A closure to execute when the header is tapped (In this view, it was used to open the CurrencyPicker sheet
///
/// The view features:
/// - Animated digits when amount changes
/// - Automatic scaling based on amount length
/// - Shadow and corner radius for visual depth
/// - Responsive layout with flexible width
	let currency: Currency
	let amount: String
	let isSource: Bool
	let onHeaderTap: () -> Void
	
// MARK: - Amount Text Display
	
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
	
// MARK: - Body
//	- Layout:
//	┌──────────────────────────────────────────────────────────┐
//	│                                                          │
//	│  From ◇ United States Dollar                             │
//	│                                                          │
//	│                                       123.456.789  USD   │
//	│                                                          │
//	└──────────────────────────────────────────────────────────┘
	
	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
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

// MARK: - Animated Digit View

struct AnimatedDigitView: View {
	let digit: Character
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

// MARK: - Extensions

extension AnyTransition {
	static var blurReplace: AnyTransition {
		.modifier(
			active: BlurModifier(blur: 20),
			identity: BlurModifier(blur: 0)
		)
	}
}

struct BlurModifier: ViewModifier {
	let blur: CGFloat
	
	func body(content: Content) -> some View {
		content.blur(radius: blur)
	}
}
