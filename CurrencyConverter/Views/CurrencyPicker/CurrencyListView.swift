//
//  CurrencyListView.swift
//  CurrencyConverter
//
//  Created by MasterBi on 12/01/2025.
//
import SwiftUI

/// A view that displays a list of currencies and allows for currency selection
///
/// # Overview
/// Presents a scrollable list of currencies with:
/// - Currency name and code display
/// - Selection indicators
/// - Disabled state handling
/// - Programmatic scrolling support
///
/// # Layout Structure
/// ```
/// ┌────────────────────────────────────────┐
/// │ United States Dollar                 ✓ │
/// │ USD                                    │
/// ├────────────────────────────────────────┤
/// │ Euro                                   │
/// │ EUR                                    │
/// ├────────────────────────────────────────┤
/// │ British Pound Sterling                 │
/// │ GBP                                    │
/// └────────────────────────────────────────┘
/// ```
///
/// # Usage Example
/// ```swift
/// CurrencyListView(
///     filteredCurrencies: currencies,
///     selectedCurrency: $selected,
///     disabledCurrency: $disabled,
///     convert: handleConversion,
///     dismissAction: dismiss,
///     scrolledID: $currentScroll
/// )
/// ```
struct CurrencyListView: View {
	/// Array of filtered currencies to display
	let filteredCurrencies: [Currency]

	/// Currently selected currency
	@Binding var selectedCurrency: Currency

	/// Currency that should be disabled from selection
	@Binding var disabledCurrency: Currency

	/// Callback to trigger currency conversion
	let convert: () -> Void

	/// Action to dismiss the currency picker
	let dismissAction: DismissAction

	/// ID of the currency to scroll to
	@Binding var scrolledID: Currency?
	
	// MARK: - Body Implementation
    
    /// Main view body implementing the currency list
    /// Features:
    /// - Selectable currency rows
    /// - Visual selection indicators
    /// - Disabled state handling
	var body: some View {
		List(filteredCurrencies, id: \.self, selection: $scrolledID) { currency in
			Button(action: {
				selectedCurrency = currency
				convert()
				dismissAction()
			}) {
				HStack {
					VStack(alignment: .leading, spacing: 4) {
						Text(currency.name)
							.font(.body)
							.foregroundColor(currency == selectedCurrency ? .blue : .primary)
						Text(currency.rawValue)
							.font(.caption)
							.foregroundColor(currency == selectedCurrency ? .blue : .secondary)
					}
					.padding(.vertical, 4)
					
					Spacer()
					
					if currency == selectedCurrency {
						Image(systemName: "checkmark")
							.foregroundColor(.blue)
					}
				}
			}
			.id(currency)
			.disabled(currency == disabledCurrency)
			.opacity(currency == disabledCurrency ? 0.5 : 1)
		}
		.listStyle(.plain)
	}
	}
