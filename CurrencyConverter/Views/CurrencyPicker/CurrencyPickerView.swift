//
//  CurrencyPickerView.swift
//  CurrencyConverter
//
//  Created by MasterBi on 12/01/2025.
//
import SwiftUI

/// A view that presents a searchable list of currencies for selection.
///
/// This view displays a list of available currencies with their names and codes, allowing users to:
/// - Search for specific currencies
/// - Select a currency (except for the disabled currency)
/// - View and update exchange rate data
///
/// The view includes:
/// - A search bar for filtering currencies
/// - A list showing currency names and codes
/// - A footer displaying data provider information and last update time
/// - Update functionality to refresh exchange rates
///
/// # Example Usage:
/// ```swift
/// CurrencyPickerView(
///     selectedCurrency: $selectedCurrency,
///     disabledCurrency: $disabledCurrency,
///     viewModel: viewModel
/// )
/// ```
///
/// - Parameters:
///   - selectedCurrency: A binding to the currently selected currency
///   - disabledCurrency: A binding to the currency that should be disabled from selection
///   - viewModel: The view model containing exchange rate data and fetch functionality
struct CurrencyPickerView: View {
	@Environment(\.dismiss) private var dismissAction
	@Binding var selectedCurrency: Currency
	@Binding var disabledCurrency: Currency
	@State private var searchText = ""
	@State private var isUpdating = false
	@ObservedObject var viewModel: CurrencyConverterViewModel
	@Namespace private var scrollSpace
	@State private var scrolledID: Currency?
	@State private var cachedUpdateTime: String = "Never"
	@State private var lastTimestamp: Int?
	
	var formattedUpdateTime: String {
		guard let timestamp = viewModel.exchangeRate?.timestamp else { return "Never" }
		let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		return formatter.localizedString(for: date, relativeTo: Date())
	}
	
	// MARK: - Footer View
	
	var footerView: some View {
	/// A view that displays the data provider and last update time. Looks like this:
	//		┌──────────────────────────────────────────────────────────┐
	//		│                                                          │
	//		│  Data provided by               Open Exchange Rates API  │
	//		│                                                          │
	//		│  Updated 1 hour ago                          Update Now  │
	//		│                                                          │
	//		└──────────────────────────────────────────────────────────┘
		
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
	
	var filteredCurrencies: [Currency] {
		if searchText.isEmpty {
			return Currency.allCases
		}
		return Currency.allCases.filter {
			($0.rawValue.localizedCaseInsensitiveContains(searchText) ||
			 $0.name.localizedCaseInsensitiveContains(searchText))
		}
	}
	
	// MARK: - Body
	
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
