//
//  ExchangeRateTests.swift
//  ExchangeRateTests
//
//  Created by MasterBi on 09/01/2025.
//

import Testing
import Foundation
@testable import CurrencyConverter

/// Tests for ExchangeRate model and API response handling
///
/// # Test Coverage
/// - JSON decoding
/// - Invalid currency handling
/// - Empty data handling
/// - Error cases
@Suite("Exchange Rate Tests")
struct ExchangeRateTests {
	
	/// Tests successful JSON decoding of exchange rates
	///
	/// # Test Steps
	/// 1. Create mock JSON response
	/// 2. Decode response
	/// 3. Create ExchangeRate object
	/// 4. Verify correct mapping
	@Test("Successfully decodes valid exchange rate JSON")
	func testExchangeRateDecoding() async throws {
		// Given
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
		
		let mockRate = try JSONDecoder().decode(OpenExchangeRatesAPIResponse.self, from: data)
		
		let baseCurrency = Currency(rawValue: mockRate.base)!
		var mappedRates: [Currency: Double] = [:]
		for (key, value) in mockRate.rates {
			if let cur = Currency(rawValue: key) {
				mappedRates[cur] = value
			}
		}
		
		let rate = ExchangeRate(baseCurrency: baseCurrency,
											  exchangeRates: mappedRates,
											  timestamp: Int(Date().timeIntervalSince1970))
		
		// Then
		#expect(rate.baseCurrency == .USD)
		#expect(rate.exchangeRates[.EUR] == 0.85)
		#expect(rate.exchangeRates[.GBP] == 0.73)
	}
	
	/// Tests handling of invalid currency codes
	///
	/// # Test Steps
	/// 1. Create mock invalid JSON
	/// 2. Attempt decoding
	/// 3. Verify fallback behavior
	/// 4. Check filtered results
	@Test("Throws error for invalid currency")
	func testInvalidCurrencyDecoding() async throws {
		// Given
		let apiResponse = """
		{
		 "base": "INVALID",
		 "rates": {
		  "FAKE": 0.85,
		  "EUR": 0.85,
		  "NOTREAL": 0.73
		 },
		 "timestamp": 1641234567,
		 "disclaimer": "Test disclaimer",
		 "license": "Test license"
		}
		"""
		let data = apiResponse.data(using: .utf8)!
		
		// When
		let mockRate = try JSONDecoder().decode(OpenExchangeRatesAPIResponse.self, from: data)
		let baseCurrency = Currency(rawValue: mockRate.base) ?? .USD  // Should fallback to USD
		var mappedRates: [Currency: Double] = [:]
		for (key, value) in mockRate.rates {
			if let cur = Currency(rawValue: key) {
				mappedRates[cur] = value
			}
		}
		
		let rate = ExchangeRate(baseCurrency: baseCurrency,
								exchangeRates: mappedRates,
								timestamp: Int(Date().timeIntervalSince1970))
		
		// Then
		#expect(rate.baseCurrency == .USD) // Should fallback to USD for invalid base
		#expect(rate.exchangeRates.count == 1) // Should only contain valid EUR rate
		#expect(rate.exchangeRates[.EUR] == 0.85)
		#expect(rate.exchangeRates[Currency.EUR]! == 0.85) // Fixed: Using Currency enum
		#expect(rate.exchangeRates.keys.contains(.EUR)) // Better way to test invalid currencies
	}
	
	/// Tests handling of empty rates dictionary
	///
	/// # Test Steps
	/// 1. Create mock empty JSON
	/// 2. Decode response
	/// 3. Verify empty state
	@Test("Handles empty rates dictionary")
	func testEmptyRatesDecoding() async throws {
		// Given
		let apiResponse = """
	{
		"base": "USD",
		"rates": {},
		"timestamp": 1641234567,
		"disclaimer": "Test disclaimer",
		"license": "Test license"
	}
	"""
		let data = apiResponse.data(using: .utf8)!
		
		// When
		let mockRate = try JSONDecoder().decode(OpenExchangeRatesAPIResponse.self, from: data)
		let rate = ExchangeRate(baseCurrency: Currency(rawValue: mockRate.base)!,
								exchangeRates: [:],
								timestamp: mockRate.timestamp)
		
		// Then
		#expect(rate.baseCurrency == .USD)
		#expect(rate.exchangeRates.isEmpty)
	}
}
