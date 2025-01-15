//
//  CustomKeypadView.swift
//  CurrencyConverter
//
//  Created by MasterBi on 12/01/2025.
//
import SwiftUI

/// A custom numeric keypad view that displays numeric buttons, a decimal separator, and a backspace.
/// It allows input handling for numeric text and provides a long-press gesture on the backspace button
/// to clear the input completely.
///
/// - Parameter amount: A binding to the text value representing the current numerical input.
///
struct CustomKeypadView: View {
	@Binding var amount: String
	
	private let buttons: [[String]] = [
		["1", "2", "3"],
		["4", "5", "6"],
		["7", "8", "9"],
		[",", "0", "⌫"]
	]
	
	/// The main content of the keypad view, featuring grid layout logic with adjustable spacing and
	/// button sizing derived from the view's available width.
	///
	/// - Note: Uses `ForEach` to create rows of buttons, each of which triggers `handleInput(_:)`
	///   or `clearInput()` when pressed or long-pressed.
	///
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
	
	/// Handles user input from the keypad by appending numeric characters or a decimal separator, and
	/// removing previous characters if the backspace button is pressed.
	///
	/// - Parameter button: The label of the pressed keypad button. It can be a numeric character,
	///   a decimal symbol, or a backspace icon.
	///
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
	
	/// Clears the entire input by setting `amount` to an empty string.
	private func clearInput() {
		amount = ""
	}
}

/// A custom button style that applies a spring animation scale effect and haptic feedback when pressed.
/// Increases the button’s size for visual emphasis and triggers a haptic response on presses.
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
