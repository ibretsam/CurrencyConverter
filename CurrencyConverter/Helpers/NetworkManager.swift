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
///     case .success(let rates):
///         // Handle exchange rates
///     case .failure(let error):
///         // Handle error
///     }
/// }
/// ```
class NetworkManager {
	static let shared = NetworkManager()
	public let service = ExchangeRatesService.OpenExchangeRatesAPI
	
	private init() {}
	
	func getExchangeRates(for service: ExchangeRatesService, completed: @escaping (Result<ExchangeRate, NetworkError>) -> Void) {
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
				print("Network error: \(error.localizedDescription)")
				completed(.failure(.noData))
				return
			}
			
			guard let response = response as? HTTPURLResponse else {
				print("Invalid response type")
				completed(.failure(.invalidResponse))
				return
			}
			
			print("Response status code: \(response.statusCode)")
			
			guard let data = data else {
				print("No data received")
				completed(.failure(.invalidData))
				return
			}
			
			do {
				print("Fetched data from api")
//				let str = String(data: data, encoding: .utf8)
//				print("Raw response: \(str ?? "nil")")
				
				let decoder = JSONDecoder()
				let exchangeRates = try decoder.decode(ExchangeRate.self, from: data)
				exchangeRates.timestamp = Int(Date().timeIntervalSince1970)
				completed(.success(exchangeRates))
			} catch {
				print("Decoding error: \(error)")
				completed(.failure(.invalidData))
			}
		}
		
		task.resume()
	}
}
