//
//  CustomKeypadView.swift
//  CurrencyConverter
//
//  Created by MasterBi on 12/01/2025.
//
import SwiftUI

/// A custom numeric keypad view for currency input handling.
///
/// # Overview
/// Provides a grid-based numeric keypad with:
/// - Numeric buttons (0-9)
/// - Decimal separator (,)
/// - Backspace button with long-press clear functionality
/// - Haptic feedback and animations
///
/// # Features
/// - Spring animations on button press
/// - Haptic feedback for user interactions
/// - Long-press to clear functionality
/// - Automatic layout adaptation
/// - Input validation and formatting
///
/// # Usage Example
/// ```swift
/// @State private var amount: String = ""
///
/// CustomKeypadView(amount: $amount)
///     .frame(height: 360)
/// ```
///
/// # Layout Structure
/// ```
/// ┌───────────────────────┐
/// │  [ 1 ]  [ 2 ]  [ 3 ]  │
/// │  [ 4 ]  [ 5 ]  [ 6 ]  │
/// │  [ 7 ]  [ 8 ]  [ 9 ]  │
/// │  [ , ]  [ 0 ]  [ ⌫ ]  │
/// └───────────────────────┘
/// ```
struct CustomKeypadView: View {
	/// Binding to the input amount string that will be modified by keypad input
	@Binding var amount: String
	
	/// Grid layout configuration for the keypad buttons
    /// Organized in a 4x3 grid with numbers, decimal, and backspace
	private let buttons: [[String]] = [
		["1", "2", "3"],
		["4", "5", "6"],
		["7", "8", "9"],
		[",", "0", "⌫"]
	]
	
    // MARK: - Body Implementation
    
    /// The main content view implementing the keypad layout
    /// Uses GeometryReader for responsive sizing and spacing
	var body: some View {
		GeometryReader { geometry in
			let spacing: CGFloat = 10
			let horizontalPadding: CGFloat = 20
			let availableWidth = geometry.size.width - (horizontalPadding * 2) - (spacing * 2)
			let buttonSize = availableWidth / 3
			
			VStack(spacing: spacing) {
				ForEach(buttons, id: \.self) { row in
					HStack(spacing: spacing) {
						ForEach(row, id: \.self) { button in
							Button(action: {
								withAnimation(.spring(response: 0.3, dampingFraction: 0.65, blendDuration: 0.9)) {
									handleInput(button)
								}
							}) {
								Text(button)
									.font(.largeTitle)
									.frame(width: buttonSize, height: buttonSize / 1.35)
							}
							.simultaneousGesture(
								LongPressGesture(minimumDuration: 0.5)
									.onEnded { _ in
										if button == "⌫" {
											withAnimation(.spring(response: 0.3, dampingFraction: 0.65, blendDuration: 0.9)) {
												clearInput()
											}
											let generator = UIImpactFeedbackGenerator(style: .heavy)
											generator.impactOccurred()
										}
									}
							)
							.contentShape(Rectangle())
							.buttonStyle(BouncyKeyStyle())
						}
					}
				}
			}
			.padding(.horizontal, horizontalPadding)
		}
		.frame(height: 360)
	}
	
    // MARK: - Private Methods
    
    /// Processes input from keypad buttons
    /// - Parameter button: The pressed button's value
    /// Handles:
    /// - Numeric input (0-9)
    /// - Decimal separator (,)
    /// - Backspace (⌫)
    /// - Input validation and formatting
	private func handleInput(_ button: String) {
		switch button {
			case "⌫":
				if !amount.isEmpty {
					amount.removeLast()
				}
			case ",":
				if !amount.contains(",") {
					amount += button
				}
			default:
				// Prevent multiple leading zeros
				if amount == "0" && button != "," {
					amount = button
				} else {
					amount += button
				}
		}
	}
	
    /// Clears the entire input amount
    /// Triggered by long-pressing the backspace button
	private func clearInput() {
		amount = ""
	}
}

/// Custom button style for keypad buttons
///
/// # Features
/// - Spring-based scale animation on press
/// - Haptic feedback using UIImpactFeedbackGenerator
/// - Visual feedback through size changes
///
/// # Animation Parameters
/// - Scale: 1.0 -> 1.8 on press
/// - Haptic feedback: Heavy impact style
struct BouncyKeyStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.scaleEffect(configuration.isPressed ? 1.8 : 1.0)
			.onChange(of: configuration.isPressed) {
				if configuration.isPressed {
					let generator = UIImpactFeedbackGenerator(style: .heavy)
					generator.impactOccurred()
				}
			}
	}
}
