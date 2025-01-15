//
//  StorageManager.swift
//  CurrencyConverter
//
//  Created by MasterBi on 12/01/2025.
//
import Foundation

/// Manages persistent storage for exchange rates and preferences
///
/// # Features
/// - Exchange rate caching
/// - Currency preferences storage
/// - JSON encoding/decoding
/// - Cache validation
///
/// # Usage Example
/// ```swift
/// let storage = StorageManager.shared
/// // Save exchange rate
/// storage.saveExchangeRate(rates)
/// // Get currency preferences
/// if let (from, to) = storage.getCurrencyPreferences() {
///     // Handle preferences
/// }
/// ```
class StorageManager {
	static let shared = StorageManager()
	private let defaults = UserDefaults.standard
	private let exchangeRateKey = "cachedExchangeRate"
	private let fromCurrencyKey = "fromCurrency"
	private let toCurrencyKey = "toCurrency"
	
	private init() {}
	
	func saveExchangeRate(_ exchangeRate: ExchangeRate) {
		let cached = CachedExchangeRate(exchangeRate: exchangeRate)
		if let encoded = try? JSONEncoder().encode(cached) {
			defaults.set(encoded, forKey: exchangeRateKey)
		}
	}
	
	func getCachedExchangeRate() -> ExchangeRate? {
		guard let data = defaults.data(forKey: exchangeRateKey),
			  let cached = try? JSONDecoder().decode(CachedExchangeRate.self, from: data),
			  cached.isValid else {
			return nil
		}
		return cached.exchangeRate
	}
	
	func saveCurrencyPreferences(from: Currency, to: Currency) {
		defaults.set(from.rawValue, forKey: fromCurrencyKey)
		defaults.set(to.rawValue, forKey: toCurrencyKey)
	}
	
	func getCurrencyPreferences() -> (from: Currency, to: Currency)? {
		guard let fromString = defaults.string(forKey: fromCurrencyKey),
			  let toString = defaults.string(forKey: toCurrencyKey),
			  let from = Currency(rawValue: fromString),
			  let to = Currency(rawValue: toString) else {
			return nil
		}
		return (from, to)
	}
}
