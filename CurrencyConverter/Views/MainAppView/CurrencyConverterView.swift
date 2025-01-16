//
//  CurrencyConverterView.swift
//  CurrencyConverter
//
//  Created by MasterBi on 09/01/2025.
//

import SwiftUI

/// The main currency converter view providing user interface for currency conversion.
///
/// # Overview
/// Manages the complete currency conversion interface including:
/// - Currency selection cards
/// - Custom numeric keypad
/// - Network state handling
/// - Error management
///
/// # Features
/// - Real-time currency conversion
/// - Offline mode with cached data
/// - Currency swapping functionality
/// - Custom numeric input
/// - Error handling and recovery
///
/// # States
/// - Online: Normal operation
/// - Offline with valid cache: Limited operation
/// - Offline with expired cache: Warning state
/// - Error: Recovery options
///
struct CurrencyConverterView: View {
	/// View model managing currency conversion logic and network state
	@StateObject var viewModel = CurrencyConverterViewModel()

	/// State controlling the source currency picker sheet
	@State private var showingFromPicker = false

	/// State controlling the target currency picker sheet
	@State private var showingToPicker = false
	
    // MARK: - Offline Banner
    
    /// Displays a warning banner when operating in offline mode with expired cache.
    /// - Shows network status
    /// - Provides retry option
    /// - Indicates cached data usage
	private var offlineBanner: some View {
		HStack {
			Image(systemName: "wifi.slash")
			Text("Cached data expired, please connect to the internet to update")
			Button("Retry") {
				viewModel.fetchExchangeRates()
			}
		}
		.padding()
		.background(Color(.systemYellow).opacity(0.2))
	}
	
    // MARK: - Error View
    
    /// Displays error state with recovery options
    /// - Parameter message: The error message to display
    /// - Returns: A view containing error UI and retry button
	private func errorView(message: String) -> some View {
		VStack(spacing: 20) {
			Image(systemName: "exclamationmark.triangle")
				.font(.largeTitle)
			Text(message)
				.multilineTextAlignment(.center)
			Button("Try Again") {
				viewModel.fetchExchangeRates()
			}
			.buttonStyle(.bordered)
		}
		.padding()
	}
	
    // MARK: - Main Content
    
    /// The primary content view containing currency cards and keypad
    /// Features:
    /// - Currency selection cards
    /// - Currency swap button
    /// - Custom numeric keypad
	private var mainContent: some View {
		VStack {
			Spacer()
			
			ZStack {
				
				VStack {
					CurrencyCard(
						currency: viewModel.fromCurrency,
						amount: viewModel.formattedAmount,
						isSource: true,
						onHeaderTap: { showingFromPicker.toggle() }
					)
					.sheet(isPresented: $showingFromPicker) {
						CurrencyPickerView(selectedCurrency: $viewModel.fromCurrency,
										   disabledCurrency: $viewModel.toCurrency,
										   viewModel: viewModel)
					}
					
					CurrencyCard(
						currency: viewModel.toCurrency,
						amount: viewModel.formattedConvertedAmount,
						isSource: false,
						onHeaderTap: { showingToPicker.toggle() }
					)
					.sheet(isPresented: $showingToPicker) {
						CurrencyPickerView(selectedCurrency: $viewModel.toCurrency,
										   disabledCurrency: $viewModel.fromCurrency,
										   viewModel: viewModel)
					}
				}
				.padding(.horizontal)
				
				Button(action: viewModel.swapCurrencies) {
					Image(systemName: "arrow.up.arrow.down.circle.fill")
						.font(.system(size: 32))
						.foregroundColor(.blue)
						.background(Color(.systemBackground))
						.clipShape(Circle())
						.shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
				}
			}
			
			Spacer()
			
			CustomKeypadView(amount: $viewModel.amount)
				.padding(.bottom, 8)
				.background(Color(.systemBackground))
		}
	}
	
    // MARK: - Body
    
    /// Main view body implementing adaptive layout based on network state
    /// Handles four states:
    /// - Online operation
    /// - Offline with valid cache
    /// - Offline with expired cache
    /// - Error state
	var body: some View {
		NavigationView {
			ZStack {
				Color(.systemGray6).ignoresSafeArea()
				
				VStack(spacing: 24) {
					switch viewModel.networkState {
						case .online:
							mainContent
						case .offlineWithValidCache:
							mainContent
						case .offlineWithExpiredCache:
							VStack {
								mainContent
								offlineBanner
							}
						case .error(let message):
							errorView(message: message)
					}
				}
			}
		}
	}
}
