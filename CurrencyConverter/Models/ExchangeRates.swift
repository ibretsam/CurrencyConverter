//
//  ExchangeRatesService.swift
//  CurrencyConverter
//
//  Created by MasterBi on 12/01/2025.
//

import Foundation

/// Models exchange rate data from multiple API services
///
/// # Features
/// - Data model for exchange rates
/// - Support for multiple currencies
/// - Timestamp tracking
/// - Manual initialization from API responses
///
/// # Usage Example
/// ```swift
/// let rate = ExchangeRate(
///     baseCurrency: .USD,
///     exchangeRates: [.EUR: 0.85, .GBP: 0.73],
///     timestamp: Int(Date().timeIntervalSince1970)
/// )
/// ```
class ExchangeRate {
	let baseCurrency: Currency
	let exchangeRates: [Currency: Double]
	var timestamp: Int
	
	init(baseCurrency: Currency, exchangeRates: [Currency: Double], timestamp: Int) {
		self.baseCurrency = baseCurrency
		self.exchangeRates = exchangeRates
		self.timestamp = timestamp
	}
}

/// Manages cached exchange rate data with expiration
///
/// # Features
/// - Configurable cache duration
/// - Expiration tracking
struct CachedExchangeRate {
	let exchangeRate: ExchangeRate
	let expirationDate: Date
	
	init(exchangeRate: ExchangeRate, expirationHours: Int = 24) {
		self.exchangeRate = exchangeRate
		self.expirationDate = Date().addingTimeInterval(TimeInterval(expirationHours * 3600))
	}
	
	var isValid: Bool {
		return Date() < expirationDate
	}
}

/// Supported exchange rate API services
///
/// # Features
/// - Multiple API support
/// - Endpoint URL generation
/// - Base currency configuration
/// - API key management
enum ExchangeRatesService: String, CaseIterable {
	case ExchangeRatesAPI = "Exchange Rates API"
	case OpenExchangeRatesAPI = "Open Exchange Rates API"
	
	private var apiKey: String {
		Config.shared.apiKey(for: self)
	}
	
	var baseCurrency: Currency {
		switch self {
			case .ExchangeRatesAPI:
				return .EUR
			case .OpenExchangeRatesAPI:
				return .USD
		}
	}
	
	var latestEndpointURL: String {
		switch self {
			case .ExchangeRatesAPI:
				return "https://api.exchangeratesapi.io/latest?access_key=\(apiKey)"
			case .OpenExchangeRatesAPI:
				return "https://openexchangerates.org/api/latest.json?app_id=\(apiKey)"
		}
	}
}

/// A model representing the response from Exchange Rates API.
///
/// This structure maps the JSON response received from the Exchange Rates API service.
struct ExchangeRatesAPIResponse: Codable {
	let success: Bool
	let timestamp: Int
	let base: String
	let date: String
	let rates: [String: Double]
}

/// A model representing the response from Open Exchange Rates API.
///
/// This structure maps the JSON response received from the Open Exchange Rates API service.
struct OpenExchangeRatesAPIResponse: Codable {
	let disclaimer: String
	let license: String
	let timestamp: Int
	let base: String
	let rates: [String: Double]
}
