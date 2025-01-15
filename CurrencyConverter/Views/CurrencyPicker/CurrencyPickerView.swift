//
//  CurrencyPickerView.swift
//  CurrencyConverter
//
//  Created by MasterBi on 12/01/2025.
//
import SwiftUI

/// A view that presents a searchable list of currencies for selection.
///
/// # Overview
/// Provides a modal interface for currency selection with:
/// - Searchable currency list
/// - Real-time filtering
/// - Exchange rate information
/// - Update functionality
///
/// # Features
/// - Currency search and filtering
/// - Disabled state for already selected currencies
/// - Auto-scroll to selected currency
/// - Update timestamp display
/// - Network state handling
///
/// # Example Usage
/// ```swift
/// CurrencyPickerView(
///     selectedCurrency: $selectedCurrency,
///     disabledCurrency: $disabledCurrency,
///     viewModel: viewModel
/// )
/// ```
struct CurrencyPickerView: View {
	/// Dismissal action for the modal view
	@Environment(\.dismiss) private var dismissAction

	/// Currently selected currency
	@Binding var selectedCurrency: Currency

	/// Currency that should be disabled from selection
	@Binding var disabledCurrency: Currency

	/// Search text for filtering currencies
	@State private var searchText = ""

	/// State for tracking update progress
	@State private var isUpdating = false

	/// View model containing exchange rate data
	@ObservedObject var viewModel: CurrencyConverterViewModel

	/// Namespace for scroll animation
	@Namespace private var scrollSpace

	/// Currently scrolled currency ID
	@State private var scrolledID: Currency?

	/// Cached update time string
	@State private var cachedUpdateTime: String = "Never"

	/// Last update timestamp
	@State private var lastTimestamp: Int?
	
	/// Formats the last update time in a human-readable format
	var formattedUpdateTime: String {
		guard let timestamp = viewModel.exchangeRate?.timestamp else { return "Never" }
		let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		return formatter.localizedString(for: date, relativeTo: Date())
	}
	
    // MARK: - Footer View
    
    /// Displays data provider information and update controls
    /// Layout:
    /// ```
    /// ┌──────────────────────────────────────────┐
    /// │ Data provided by     Open Exchange Rates │
    /// │ Updated 1 hour ago            Update Now │
    /// └──────────────────────────────────────────┘
    /// ```
	var footerView: some View {
		VStack {
			HStack {
				Text("Data provided by")
					.font(.footnote)
					.foregroundColor(.secondary)
				Spacer()
				Text(NetworkManager.shared.service.rawValue)
					.foregroundColor(.secondary)
					.font(.callout)
			}
			
			HStack {
				Text("Updated \(formattedUpdateTime)")
					.foregroundColor(.secondary)
					.font(.footnote)
				Spacer()
				Button(action: {
					isUpdating = true
					viewModel.fetchExchangeRates()
					// Add delay to show loading state
					DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
						isUpdating = false
					}
				}) {
					HStack {
						if isUpdating {
							ProgressView()
								.progressViewStyle(CircularProgressViewStyle(tint: .white))
								.scaleEffect(0.8)
						}
						Text(isUpdating ? "Updating..." : "Update now")
							.font(.callout)
					}
				}
				.disabled(isUpdating)
			}
		}
		.padding()
		.background(Color(.systemGray5))
		.overlay(
			Rectangle()
				.frame(height: 1)
				.foregroundColor(Color(.separator))
				.opacity(0.5),
			alignment: .top
		)
	}
	
    // MARK: - Filtered Currencies
    
    /// Returns filtered currency list based on search text
    /// - Returns: Filtered array of Currency enum cases
	var filteredCurrencies: [Currency] {
		if searchText.isEmpty {
			return Currency.allCases
		}
		return Currency.allCases.filter {
			($0.rawValue.localizedCaseInsensitiveContains(searchText) ||
			 $0.name.localizedCaseInsensitiveContains(searchText))
		}
	}
	
    // MARK: - Body Implementation
    
    /// Main view body with navigation and search functionality
	var body: some View {
		NavigationView {
			ScrollViewReader { proxy in
				VStack(spacing: 0) {
					CurrencyListView(
						filteredCurrencies: filteredCurrencies,
						selectedCurrency: $selectedCurrency,
						disabledCurrency: $disabledCurrency,
						convert: viewModel.convert,
						dismissAction: dismissAction,
						scrolledID: $scrolledID
					)
					
					footerView
				}
				.navigationTitle("Select Currency")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .navigationBarTrailing) {
						Button("Done") {
							dismissAction()
						}
					}
				}
				.searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search currency")
				.onAppear {
					proxy.scrollTo(selectedCurrency, anchor: .center)
				}
				.onChange(of: searchText) {
					if let first = filteredCurrencies.first {
						proxy.scrollTo(first, anchor: .top)
					}
				}
			}
		}
	}
}
