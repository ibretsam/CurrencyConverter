//
//  CurrencyConverterViewModel.swift
//  CurrencyConverter
//
//  Created by MasterBi on 12/01/2025.
//

import Foundation
import Combine

/// ViewModel for handling currency conversion logic and state management.
///
/// This class manages:
/// - Currency conversion operations
/// - Network state monitoring
/// - Cache management
/// - Error handling
///
/// # Error Handling
///
/// ## Network States
/// See `Helpers/NetworkMonitor.NetworkState` for state definitions.
///
/// ## Error Scenarios & Recovery
///
/// 1. Network Unavailable
///    - With Valid Cache:
///      * Sets `.offlineWithValidCache`
///      * Uses cached exchange rates
///      * Shows offline banner
///    - With Expired Cache:
///      * Sets `.offlineWithExpiredCache`
///      * Uses cached data with warning
///      * Shows update prompt
///    - No Cache:
///      * Sets `.error`
///      * Disables conversion
///      * Shows error message
///
/// 2. API Request Failures
///    - With Cache:
///      * Falls back to cached data
///      * Sets appropriate offline state
///      * Shows offline indicator
///    - No Cache:
///      * Shows error message
///      * Disables conversion
///      * Provides retry option
///
/// 3. Data Parsing Errors
///    - Invalid Response:
///      * Attempts to use cached data
///      * Shows parsing error if no cache
///    - Missing Fields:
///      * Uses partial data if possible
///      * Falls back to cache otherwise
///
/// ## Auto-Recovery
/// - Monitors network connectivity changes
/// - Auto-refreshes when connection restored
/// - Maintains operation with cached data
/// - Updates UI state automatically
class CurrencyConverterViewModel: ObservableObject {
	// MARK: - Published Properties
	
	/// The current exchange rate data containing all conversion rates
	@Published var exchangeRate: ExchangeRate?
	
	/// Current error message to display, if any.
	/// This is set when:
	/// - There is a network error and no cached data is available.
	/// - There is a failure in fetching exchange rates from the API.
	/// - There is a data parsing error.
	@Published var errorMessage: String?
	
	/// Source currency for conversion
	/// Updates preferences automatically when changed
	@Published var fromCurrency: Currency {
		didSet {
			storage.saveCurrencyPreferences(from: fromCurrency, to: toCurrency)
		}
	}
	
	/// Target currency for conversion
	/// Updates preferences automatically when changed
	@Published var toCurrency: Currency {
		didSet {
			storage.saveCurrencyPreferences(from: fromCurrency, to: toCurrency)
		}
	}
	
	/// Current network state of the application
	/// Used to determine UI state and functionality
	@Published var networkState: NetworkState = .online
	
	// MARK: - Input Handling
	
	/// Raw amount string input from the user
	/// Handles special cases:
	/// - Decimal point input (. or ,)
	/// - Leading zeros
	/// - Format validation
	var amount: String = "0" {
		didSet {
			// Handle decimal input
			if amount == "." || amount == "," {
				amount = "0."
				formattedAmount = "0,"
				return
			}
			
			// Handle decimal numbers
			if let number = Double(amount.replacingOccurrences(of: ",", with: ".")) {
				// Format with at least one digit before decimal
				let formattedString = numberFormatter.string(from: NSNumber(value: number)) ?? amount
				if formattedString.hasPrefix(",") {
					formattedAmount = "0" + formattedString
				} else {
					formattedAmount = formattedString
				}
			} else {
				formattedAmount = amount
			}
			convert()
		}
	}
	
	/// The converted amount in the target currency.
	/// This value is calculated by taking the input amount in the source currency
	/// and converting it using the current exchange rates.
	/// If the input amount is zero or no exchange rates are available, the converted amount is set to zero.
	@Published var convertedAmount: Double = 0
	
	/// Formatted display version of the input amount.
	/// This property is used to store the user input amount in a formatted manner.
	/// It handles special cases such as decimal point input and leading zeros.
	/// The formatted amount is updated whenever the `amount` property is set.
	/// This ensures that the displayed amount is always in a user-friendly format.
	@Published private(set) var formattedAmount: String = "0"
	
	/// Formatted display version of the converted amount.
	/// Uses scientific notation for very large numbers (>=1T) to ensure readability.
	/// For smaller numbers, uses standard decimal format with appropriate grouping.
	var formattedConvertedAmount: String {
		if abs(convertedAmount) >= 1_000_000_000_000 {
			return scientificFormatter.string(from: NSNumber(value: convertedAmount)) ?? String(format: "%.2f", convertedAmount)
		}
		return numberFormatter.string(from: NSNumber(value: convertedAmount)) ?? String(format: "%.2f", convertedAmount)
	}
	
	// MARK: - Private Properties
	
	private let service = CurrencyConverterServices.shared
	private let storage = StorageManager.shared
	private var cancellables = Set<AnyCancellable>()
	private let networkMonitor = NetworkMonitor.shared
	
	// MARK: - Initialization
	
	/// Initializes the view model and sets up the initial state.
	///
	/// This includes:
	/// - Loading currency preferences from storage or setting default values.
	/// - Loading initial exchange rates from cache or network.
	/// - Setting up network state monitoring to handle connectivity changes.
	/// - Observing network state changes to update the UI and handle errors.
	///
	/// The initialization ensures that the view model is ready to handle currency conversion
	/// operations and manage the state of the currency converter application.
	init() {
		if let preferences = storage.getCurrencyPreferences() {
			self.fromCurrency = preferences.from
			self.toCurrency = preferences.to
		} else {
			self.fromCurrency = .USD
			self.toCurrency = .EUR
		}
		
		loadExchangeRates()
		
		// Only observe network state changes for error handling
		networkMonitor.$isConnected
			.receive(on: DispatchQueue.main)
			.sink { [weak self] isConnected in
				guard let self = self else { return }
				if !isConnected {
					if self.storage.getCachedExchangeRate() != nil {
						self.networkState = .offlineWithValidCache
					} else {
						self.networkState = .offlineWithExpiredCache
					}
				} else {
					self.networkState = .online
				}
			}
			.store(in: &cancellables)
	}
	
	// MARK: - Private Methods
	
	/// Loads exchange rates from cache or network
	/// Priority:
	/// 1. Valid cache
	/// 2. Network request if cache invalid/missing
	/// 3. Error state if both fail
	private func loadExchangeRates() {
		if let cached = storage.getCachedExchangeRate() {
			self.exchangeRate = cached
			self.networkState = networkMonitor.isConnected ?
				.online :
				.offlineWithValidCache
			
			if !networkMonitor.isConnected {
				return
			}
			return
		}
		
		if networkMonitor.isConnected {
			fetchExchangeRates()
		} else {
			self.networkState = .error("No internet connection and no cached data available")
		}
	}
	
	// MARK: - Public Methods
	
	/// Fetches fresh exchange rates from the API
	/// Falls back to cache if network unavailable
	/// Updates network state based on result
	public func fetchExchangeRates() {
		guard networkMonitor.isConnected else {
			if let cached = storage.getCachedExchangeRate() {
				self.exchangeRate = cached
				self.networkState = .offlineWithValidCache
			} else {
				self.networkState = .error("No internet connection and no cached data available")
			}
			return
		}
		
		service.fetchExchangeRates { [weak self] result in
			guard let self = self else { return }
			
			switch result {
				case .success(let exchangeRate):
					self.exchangeRate = exchangeRate
					self.networkState = .online
					self.storage.saveExchangeRate(exchangeRate)
					
				case .failure(let error):
					if let cached = self.storage.getCachedExchangeRate() {
						self.exchangeRate = cached
						// Keep offline state instead of showing error
						self.networkState = .offlineWithValidCache
					} else {
						self.networkState = .error(error.localizedDescription)
					}
			}
		}
	}
	
	/// Converts the current amount between selected currencies
	/// Uses latest exchange rates or cached rates if offline
	/// Sets convertedAmount to 0 if:
	/// - Input amount is empty
	/// - Input amount is 0
	/// - No exchange rates available
	func convert() {
		if amount.isEmpty {
			amount = "0"
		}
		
		guard let number = numberFormatter.number(from: amount) else { return }
		let doubleAmount = Double(truncating: number)
		
		if doubleAmount == 0 {
			convertedAmount = 0
			return
		}
		
		guard let rates = exchangeRate?.exchangeRates else { return }
		
		if let targetRate = rates[toCurrency] {
			let baseRate = rates[fromCurrency] ?? 1.0
			convertedAmount = (doubleAmount / baseRate) * targetRate
		}
	}
	
	/// Swaps the source and target currencies.
	///
	/// This method exchanges the values of `fromCurrency` and `toCurrency`.
	/// It is useful when the user wants to quickly reverse the direction of the currency conversion.
	/// After swapping the currencies, it automatically triggers the conversion process to update the converted amount.
	/// The method ensures that the UI reflects the new conversion direction immediately.
	func swapCurrencies() {
		let temp = fromCurrency
		fromCurrency = toCurrency
		toCurrency = temp
		convert()
	}
}
