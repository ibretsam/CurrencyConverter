//
//  StorageManagerTests.swift
//  CurrencyConverter
//
//  Created by MasterBi on 15/01/2025.
//

import Testing
import Foundation
@testable import CurrencyConverter

/// Tests for StorageManager persistent storage functionality
///
/// # Test Coverage
/// - Exchange rate caching
/// - Currency preferences persistence
/// - Cache invalidation
/// - Data persistence between app launches
@Suite("Storage Manager Tests")
struct StorageManagerTests {
	
	/// Tests exchange rate caching functionality
	///
	/// # Test Steps
	/// 1. Clear existing cache
	/// 2. Create mock exchange rate data
	/// 3. Save to persistent storage
	/// 4. Retrieve cached data
	/// 5. Verify data integrity
	@Test("Successfully caches exchange rates")
	func testExchangeRateCaching() async throws {
		// Given
		let storage = StorageManager.shared
		UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
		let apiResponse = """
		{
		   "base": "USD",
		   "rates": {
				"EUR": 0.85,
				"GBP": 0.73
			},
			"timestamp": 1641234567,
			"disclaimer": "Test disclaimer",
			"license": "Test license"
		}
		"""
		let data = apiResponse.data(using: .utf8)!
		
		// Decode API response first
		let mockRate = try JSONDecoder().decode(OpenExchangeRatesAPIResponse.self, from: data)
		
		// Convert to ExchangeRate
		let baseCurrency = Currency(rawValue: mockRate.base)!
		var mappedRates: [Currency: Double] = [:]
		for (key, value) in mockRate.rates {
			if let cur = Currency(rawValue: key) {
				mappedRates[cur] = value
			}
		}
		
		let rate = ExchangeRate(baseCurrency: baseCurrency,
								exchangeRates: mappedRates,
								timestamp: mockRate.timestamp)
		
		// When
		storage.saveExchangeRate(rate)
		let cached = storage.getCachedExchangeRate()
		
		// Then
		#expect(cached != nil)
		#expect(cached?.baseCurrency == .USD)
		#expect(cached?.exchangeRates[.EUR] == 0.85)
	}
	
	/// Tests currency preferences storage and retrieval
	///
	/// # Test Steps
	/// 1. Clear existing preferences
	/// 2. Save new currency preferences
	/// 3. Retrieve saved preferences
	/// 4. Verify preference values
	@Test("Successfully stores and retrieves currency preferences")
	func testCurrencyPreferences() async throws {
		// Given
		let storage = StorageManager.shared
		UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
		
		// When
		storage.saveCurrencyPreferences(from: .USD, to: .EUR)
		let preferences = storage.getCurrencyPreferences()
		
		// Then
		#expect(preferences != nil)
		#expect(preferences?.from == .USD)
		#expect(preferences?.to == .EUR)
	}
}
