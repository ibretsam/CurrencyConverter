//
//  CurrencyConverterServices.swift
//  CurrencyConverter
//
//  Created by MasterBi on 12/01/2025.
//
import Foundation

/// A service responsible for handling currency conversion operations.
///
/// This service provides functionality to fetch current exchange rates from external APIs.
///
/// Example usage:
/// ```
/// let service = CurrencyConverterServices.shared
/// service.fetchExchangeRates { result in
///     switch result {
///     case .success(let rates):
///         // Handle the exchange rates
///     case .failure(let error):
///         // Handle the error
///     }
/// }
/// ```
protocol CurrencyConverterServicing {
    /// Fetches current exchange rates from the server.
    ///
    /// - Parameter completion: A closure that receives either the exchange rates or an error.
    ///   The closure takes a single parameter of type `Result<ExchangeRate, NetworkError>`.
    ///   - On success: Returns `ExchangeRate` containing current exchange rates.
    ///   - On failure: Returns `NetworkError` describing what went wrong.
    func fetchExchangeRates(completion: @escaping (Result<ExchangeRate, NetworkError>) -> Void)
}

/// A concrete implementation of `CurrencyConverterServicing` that handles currency conversion operations.
///
/// This class follows the singleton pattern and interfaces with a `NetworkManager` to fetch exchange rates.
final class CurrencyConverterServices: CurrencyConverterServicing {
    /// The shared instance of `CurrencyConverterServices`.
    static let shared = CurrencyConverterServices()
    
    /// The network manager used for making API requests.
    private let networkManager = NetworkManager.shared
    
    /// Private initializer to enforce singleton pattern.
    private init() {}
    
    /// Fetches current exchange rates from OpenExchangeRates API.
    ///
    /// This method makes an asynchronous network request and returns the result on the main thread.
    ///
    /// - Parameter completion: A closure that receives either the exchange rates or an error.
    ///   The closure takes a single parameter of type `Result<ExchangeRate, NetworkError>`.
    ///   - On success: Returns `ExchangeRate` containing current exchange rates.
    ///   - On failure: Returns `NetworkError` describing what went wrong.
	func fetchExchangeRates(completion: @escaping (Result<ExchangeRate, NetworkError>) -> Void) {
		networkManager.getExchangeRates(for: .OpenExchangeRatesAPI) { result in
			DispatchQueue.main.async {
				completion(result)
			}
		}
	}
}
