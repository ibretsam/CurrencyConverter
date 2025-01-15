//
//  CurrencyListView.swift
//  CurrencyConverter
//
//  Created by MasterBi on 12/01/2025.
//
import SwiftUI

/// A view that displays a list of currencies and allows for currency selection
///
/// This view presents a scrollable list of currencies where users can select a currency,
/// with visual indicators for the currently selected and disabled currencies.
///
/// - Parameters:
///   - filteredCurrencies: An array of `Currency` objects to display in the list
///   - selectedCurrency: A binding to the currently selected currency
///   - disabledCurrency: A binding to a currency that should be disabled in the list
///   - convert: A closure to trigger conversion when a selection is made
///   - dismissAction: An action to dismiss the view when a selection is made
///   - scrolledID: A binding to track the currently scrolled currency for programmatic scrolling
///
/// The view provides the following features:
/// - Displays currency name and code
/// - Shows a checkmark for the selected currency
/// - Highlights selected currency in blue
/// - Disables and dims the disabled currency
/// - Supports programmatic scrolling through `scrolledID` binding
struct CurrencyListView: View {
	let filteredCurrencies: [Currency]
	@Binding var selectedCurrency: Currency
	@Binding var disabledCurrency: Currency
	let convert: () -> Void
	let dismissAction: DismissAction
	@Binding var scrolledID: Currency?
	
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
