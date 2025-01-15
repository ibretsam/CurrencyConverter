//
//  StorageManager.swift
//  CurrencyConverter
//
//  Created by MasterBi on 12/01/2025.
//
import Foundation

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
