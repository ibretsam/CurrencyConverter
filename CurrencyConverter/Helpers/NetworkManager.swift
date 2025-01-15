//
//  NetworkManager.swift
//  CurrencyConverter
//
//  Created by MasterBi on 11/01/2025.
//
import Foundation

/// Manages network requests for exchange rate data
///
/// # Features
/// - Singleton pattern implementation
/// - API request handling
/// - Response validation and parsing
/// - Error handling with NetworkError types
///
/// # Usage Example
/// ```swift
/// NetworkManager.shared.getExchangeRates(for: .OpenExchangeRatesAPI) { result in
///     switch result {
///     case .success(let exchangeRate):
///         // Handle exchange rate object directly
///     case .failure(let error):
///         // Handle specific NetworkError cases
///     }
/// }
/// ```
class NetworkManager {
	static let shared = NetworkManager()
	public let service = ExchangeRatesService.ExchangeRatesAPI
	
	private init() {}
	
	func getExchangeRates(for service: ExchangeRatesService,
						  completed: @escaping (Result<ExchangeRate, NetworkError>) -> Void) {
		let endpointURL = service.latestEndpointURL
		guard let url = URL(string: endpointURL) else {
			completed(.failure(.invalidURL))
			return
		}
		
		var request = URLRequest(url: url)
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpMethod = "GET"
		
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				completed(.failure(.networkError(error)))
				return
			}
			guard let httpResponse = response as? HTTPURLResponse,
				  (200...299).contains(httpResponse.statusCode),
				  let data = data else {
				completed(.failure(.invalidResponse))
				return
			}
			
			do {
				let decoder = JSONDecoder()
				print("fetched api data")
				switch service {
					case .ExchangeRatesAPI:
						let apiResponse = try decoder.decode(ExchangeRatesAPIResponse.self, from: data)
						print("ExchangeRatesAPIResponse")
						let base = Currency(rawValue: apiResponse.base) ?? .EUR
						var mappedRates: [Currency: Double] = [:]
						for (key, value) in apiResponse.rates {
							if let cur = Currency(rawValue: key) {
								mappedRates[cur] = value
							}
						}
						let exchangeRate = ExchangeRate(baseCurrency: base,
														exchangeRates: mappedRates,
														timestamp: Int(Date().timeIntervalSince1970))
						completed(.success(exchangeRate))
						
					case .OpenExchangeRatesAPI:
						let apiResponse = try decoder.decode(OpenExchangeRatesAPIResponse.self, from: data)
						print("OpenExchangeRatesAPIResponse")
						let base = Currency(rawValue: apiResponse.base) ?? .USD
						var mappedRates: [Currency: Double] = [:]
						for (key, value) in apiResponse.rates {
							if let cur = Currency(rawValue: key) {
								mappedRates[cur] = value
							}
						}
						let exchangeRate = ExchangeRate(baseCurrency: base,
														exchangeRates: mappedRates,
														timestamp: Int(Date().timeIntervalSince1970))
						completed(.success(exchangeRate))
				}
			} catch {
				completed(.failure(.invalidData))
			}
		}
		
		task.resume()
	}
}
