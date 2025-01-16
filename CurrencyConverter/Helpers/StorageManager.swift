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
	
	/// Saves the provided exchange rate information to UserDefaults.
	/// - Parameter exchangeRate: The exchange rate object to be saved, containing base currency, timestamp, and exchange rates.
	/// The data is stored as a dictionary with the following structure:
	/// ```
	/// [
	///     "baseCurrency": String,
	///     "timestamp": TimeInterval,
	///     "exchangeRates": [String: Double],
	///     "expirationTimestamp": TimeInterval
	/// ]
	/// ```
	/// The exchange rate data is set to expire after 24 hours from the save time.
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
	
	/// Retrieves the cached exchange rate data from UserDefaults.
	///
	/// This method attempts to retrieve and reconstruct an `ExchangeRate` object from cached data.
	/// The cached data includes the base currency, timestamp, exchange rates dictionary, and expiration timestamp.
	///
	/// - Returns: An `ExchangeRate` object if valid cached data exists and hasn't expired, otherwise `nil`.
	///
	/// The method will return `nil` in the following cases:
	/// - Required data is missing or malformed in UserDefaults
	/// - The cached data has expired (current time exceeds expiration timestamp)
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
	
	/// Saves the user's preferred currency pair to persistent storage.
	/// - Parameters:
	///   - from: The base currency to convert from
	///   - to: The target currency to convert to
	func saveCurrencyPreferences(from: Currency, to: Currency) {
		defaults.set(from.rawValue, forKey: fromCurrencyKey)
		defaults.set(to.rawValue, forKey: toCurrencyKey)
	}
	
	/// Retrieves the user's preferred currency conversion pair from UserDefaults.
	/// - Returns: A tuple containing the source (`from`) and target (`to`) currencies if both values exist and are valid,
	///           or `nil` if either currency preference is missing or invalid.
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
