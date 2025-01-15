//
//  ExchangeRatesService.swift
//  CurrencyConverter
//
//  Created by MasterBi on 12/01/2025.
//

import Foundation

class ExchangeRate: Codable {
	let baseCurrency: Currency
	let exchangeRates: [Currency: Double]
	var timestamp: Int
	let disclaimer: String
	let license: String
	
	enum CodingKeys: String, CodingKey {
		case baseCurrency = "base"
		case exchangeRates = "rates"
		case timestamp
		case disclaimer
		case license
	}
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		// Decode base currency
		let baseString = try container.decode(String.self, forKey: .baseCurrency)
		guard let base = Currency(rawValue: baseString) else {
			throw DataError.invalidCurrency
		}
		baseCurrency = base
		
		// Decode rates dictionary
		let ratesDict = try container.decode([String: Double].self, forKey: .exchangeRates)
		var rates: [Currency: Double] = [:]
		
		for (key, value) in ratesDict {
			if let currency = Currency(rawValue: key) {
				rates[currency] = value
			}
		}
		
		exchangeRates = rates
		timestamp = try container.decode(Int.self, forKey: .timestamp)
		disclaimer = try container.decode(String.self, forKey: .disclaimer)
		license = try container.decode(String.self, forKey: .license)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(baseCurrency.rawValue, forKey: .baseCurrency)
		
		// Convert Currency keys to String keys for encoding
		var stringRates: [String: Double] = [:]
		for (key, value) in exchangeRates {
			stringRates[key.rawValue] = value
		}
		try container.encode(stringRates, forKey: .exchangeRates)
		
		try container.encode(timestamp, forKey: .timestamp)
		try container.encode(disclaimer, forKey: .disclaimer)
		try container.encode(license, forKey: .license)
	}
}

struct CachedExchangeRate: Codable {
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
				return "https://api.exchangeratesapi.io/latest?api_key=\(apiKey)"
			case .OpenExchangeRatesAPI:
				return "https://openexchangerates.org/api/latest.json?app_id=\(apiKey)"
		}
	}
}
