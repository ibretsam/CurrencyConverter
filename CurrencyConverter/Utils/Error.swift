//
//  Error.swift
//  CurrencyConverter
//
//  Created by MasterBi on 12/01/2025.
//
import Foundation

/// Network-related errors that can occur during API operations
///
/// # Usage Example
/// ```swift
/// throw NetworkError.noInternet
/// ```
///
/// # Error Handling Example
/// ```swift
/// do {
///     try await fetchData()
/// } catch let error as NetworkError {
///     print(error.errorDescription)
/// }
/// ```
enum NetworkError: LocalizedError {
	// MARK: - Error Cases

	/// No internet connection available
	case noInternet

	/// The URL is malformed or invalid
	case invalidURL

	/// Server response is not in expected format
	case invalidResponse

	/// Response data cannot be parsed
	case invalidData

	/// Server returned empty response
	case noData

	/// Underlying network error
	case networkError(Error)

	/// Cached exchange rates have expired
	case expired
	
	// MARK: - LocalizedError Implementation
    
    /// Human-readable error descriptions
	var errorDescription: String? {
		switch self {
			case .noInternet: return "No internet connection"
			case .invalidURL: return "Invalid URL"
			case .invalidResponse: return "Server returned an invalid response"
			case .invalidData: return "Could not parse server response"
			case .noData: return "Server returned no data"
			case .networkError(let error): return error.localizedDescription
			case .expired: return "Exchange rates data has expired"
		}
	}
}

/// Data handling and validation errors
///
/// # Usage Example
/// ```swift
/// throw DataError.invalidCurrency
/// ```
enum DataError: LocalizedError {
	// MARK: - Error Cases
    
    /// Data is corrupted or in wrong format
	case invalidData

	/// Currency code is not valid
	case invalidCurrency
	
	// MARK: - LocalizedError Implementation
    
    /// Human-readable error descriptions
	var errorDescription: String? {
		switch self {
			case .invalidData: return "The data is invalid or corrupted"
			case .invalidCurrency: return "The currency is invalid"
		}
	}
}
