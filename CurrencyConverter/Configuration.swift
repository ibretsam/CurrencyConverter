//
//  Configuration.swift
//  CurrencyConverter
//
//  Created by MasterBi on 14/01/2025.
//
import Foundation

struct Config{
	static let shared = Config()
	private let dictionary: [String: Any]
	
	private init() {
		guard let path = Bundle.main.path(forResource: "Configuration", ofType: "plist"),
			  let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
			fatalError("Configuration.plist not found")
		}
		self.dictionary = dict
	}
	
	func apiKey(for service: ExchangeRatesService) -> String {
		switch service {
			case .ExchangeRatesAPI:
				return dictionary["ExchangeRatesAPIKey"] as? String ?? ""
			case .OpenExchangeRatesAPI:
				return dictionary["OpenExchangeRatesAPIKey"] as? String ?? ""
		}
	}
}
