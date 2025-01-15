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
/// storage.saveExchangeRate(exchangeRate)
/// // Get currency preferences
/// if let preferences = storage.getCurrencyPreferences() {
///     let fromCurrency = preferences.from
///     let toCurrency = preferences.to
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
		print("Saving exchange rate")
		var dict: [String: Any] = [:]
		dict["baseCurrency"] = exchangeRate.baseCurrency.rawValue
		// Store as Int
		dict["timestamp"] = exchangeRate.timestamp
		
		var ratesDict: [String: Double] = [:]
		for (cur, val) in exchangeRate.exchangeRates {
			ratesDict[cur.rawValue] = val
		}
		dict["exchangeRates"] = ratesDict
		
		let expirationDate = Date().addingTimeInterval(24 * 3600)
		dict["expirationTimestamp"] = expirationDate.timeIntervalSince1970
		
		defaults.set(dict, forKey: exchangeRateKey)
		print("Exchange rate saved")
	}
	
	func getCachedExchangeRate() -> ExchangeRate? {
		print("Getting cached exchange rate")
		guard let dict = defaults.dictionary(forKey: exchangeRateKey),
			  let baseStr = dict["baseCurrency"] as? String,
			  let timestamp = dict["timestamp"] as? Int,
			  let ratesDict = dict["exchangeRates"] as? [String: Double],
			  let expirationTS = dict["expirationTimestamp"] as? TimeInterval
		else {
			return nil
		}
		if Date().timeIntervalSince1970 > expirationTS {
			return nil
		}
		let base = Currency(rawValue: baseStr) ?? .USD
		var mappedRates: [Currency: Double] = [:]
		for (curStr, val) in ratesDict {
			if let c = Currency(rawValue: curStr) {
				mappedRates[c] = val
			}
		}
		
		print("Exchange rate retrieved")
		return ExchangeRate(baseCurrency: base, exchangeRates: mappedRates, timestamp: timestamp)
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
