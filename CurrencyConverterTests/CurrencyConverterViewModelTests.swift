//
//  CurrencyConverterViewModelTests.swift
//  CurrencyConverter
//
//  Created by MasterBi on 15/01/2025.
//

import Testing
import Foundation
@testable import CurrencyConverter

/// Tests for CurrencyConverterViewModel business logic
///
/// # Test Coverage
/// - Currency conversion calculations
/// - Currency swapping
/// - Amount formatting
/// - Network state management
/// - Offline mode handling
@Suite("Currency Converter ViewModel Tests")
struct CurrencyConverterViewModelTests {
	
	/// Tests basic currency conversion functionality
	///
	/// # Test Steps
	/// 1. Setup mock exchange rates
	/// 2. Configure currencies
	/// 3. Perform conversion
	/// 4. Verify conversion result
	@Test("Converts currency correctly")
	func testCurrencyConversion() async throws {
		// Given
		let viewModel = CurrencyConverterViewModel()
		
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
		
		viewModel.exchangeRate = ExchangeRate(baseCurrency: baseCurrency,
											   exchangeRates: mappedRates,
											   timestamp: Int(Date().timeIntervalSince1970))
		viewModel.fromCurrency = .USD
		viewModel.toCurrency = .EUR
		
		// When
		viewModel.amount = "100"
		viewModel.convert()
		
		// Then
		#expect(viewModel.convertedAmount == 85.0)
	}
	
	/// Tests currency swap operation
	///
	/// # Test Steps
	/// 1. Set initial currencies
	/// 2. Perform swap
	/// 3. Verify new positions
	@Test("Swaps currencies correctly")
	func testCurrencySwap() async {
		// Given
		let viewModel = CurrencyConverterViewModel()
		viewModel.fromCurrency = .USD
		viewModel.toCurrency = .EUR
		
		// When
		viewModel.swapCurrencies()
		
		// Then
		#expect(viewModel.fromCurrency == .EUR)
		#expect(viewModel.toCurrency == .USD)
	}
	
	/// Tests amount formatting for different inputs
	///
	/// # Test Steps
	/// 1. Define test cases
	/// 2. Process each input
	/// 3. Verify formatted output
	@Test("Formats currency amounts correctly")
	func testAmountFormatting() async {
		// Given
		let viewModel = CurrencyConverterViewModel()
		
		// Test cases
		let cases = [
			("1", "1"),
			("1.0", "1"),
			("1.23", "1,23"),
			("1000", "1.000"),
			("1000000", "1.000.000"),
			(",", "0,"),
			(".", "0,")
		]
		
		// Then
		for (input, expected) in cases {
			viewModel.amount = input
			#expect(viewModel.formattedAmount == expected)
		}
	}
	
	/// Tests network state transitions
	///
	/// # Test Steps
	/// 1. Test offline transition
	/// 2. Verify cache handling
	/// 3. Test online transition
	/// 4. Verify state updates
	@Test("Updates network state correctly")
	func testNetworkStateChanges() async throws {
		// Given
		let viewModel = CurrencyConverterViewModel()
		
		// When offline with valid cache
		NetworkMonitor.shared.isConnected = false
		StorageManager.shared.saveExchangeRate(ExchangeRate(baseCurrency: .USD,
															exchangeRates: [.EUR: 0.85],
															timestamp: Int(Date().timeIntervalSince1970)))
		
		// Wait for state to update
		try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
		
		// Then
		#expect(viewModel.networkState == NetworkState.offlineWithValidCache)
		
		// When back online
		NetworkMonitor.shared.isConnected = true
		
		// Wait for state to update
		try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
		
		// Then
		#expect(viewModel.networkState == NetworkState.online)
	}
}
