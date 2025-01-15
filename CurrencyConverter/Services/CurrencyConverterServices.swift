//
//  CurrencyConverterServices.swift
//  CurrencyConverter
//
//  Created by MasterBi on 12/01/2025.
//
import Foundation

/// Protocol defining currency conversion service operations
///
/// # Features
/// - Asynchronous exchange rate fetching
/// - Error handling with NetworkError
/// - Completion-based API
///
/// # Usage Example
/// ```swift
/// let service = CurrencyConverterServices.shared
/// service.fetchExchangeRates { result in
///     switch result {
///     case .success(let rates):
///         // Handle exchange rates
///     case .failure(let error):
///         // Handle error
///     }
/// }
/// ```
protocol CurrencyConverterServicing {
    /// Fetches current exchange rates from the server
    ///
    /// # Parameters
    /// - completion: Result callback with ExchangeRate or NetworkError
    ///
    /// # Thread Safety
    /// Completion handler is always called on the main thread
    func fetchExchangeRates(completion: @escaping (Result<ExchangeRate, NetworkError>) -> Void)
}

/// Implementation of CurrencyConverterServicing protocol
///
/// # Features
/// - Singleton pattern implementation
/// - Thread-safe network operations
/// - Automatic main thread completion
///
/// # Architecture
/// ```
/// ┌─────────────────────┐
/// │ CurrencyConverter   │
/// │     Services        │
/// └─────────┬───────────┘
///           │
/// ┌─────────▼───────────┐
/// │   NetworkManager    │
/// └───────────────────┬─┘
///                     │
/// ┌───────────────────▼─┐
/// │      API Layer      │
/// └───────────────────┬─┘
///                     │
/// ┌───────────────────▼─┐
/// │   Exchange Rates    │
/// └─────────────────────┘
/// ```
final class CurrencyConverterServices: CurrencyConverterServicing {
    /// Shared singleton instance
    static let shared = CurrencyConverterServices()
    
    /// Network manager instance for API requests
    private let networkManager = NetworkManager.shared
    
    /// Private initializer for singleton pattern
    private init() {}
    
    /// Fetches exchange rates from API
    ///
    /// # Threading
    /// - Network calls run on background thread
    /// - Completion always delivered on main thread
    ///
    /// # Error Handling
    /// - NetworkError.noInternet: No connection
    /// - NetworkError.invalidData: Parse failure
    /// - NetworkError.expired: Cache expired
	func fetchExchangeRates(completion: @escaping (Result<ExchangeRate, NetworkError>) -> Void) {
		networkManager.getExchangeRates(for: .OpenExchangeRatesAPI) { result in
			DispatchQueue.main.async {
				completion(result)
			}
		}
	}
}
