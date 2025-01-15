//
//  CurrencyConverterView.swift
//  CurrencyConverter
//
//  Created by MasterBi on 09/01/2025.
//

import SwiftUI

///	 # CurrencyConverterView
///
///	 A SwiftUI view managing currency conversion operations, including:
///	 - Observing a `CurrencyConverterViewModel` for exchange rate data and connectivity updates.
///	 - Displaying an offline banner with a retry button when the network is offline.
///	 - Handling an error state with a retry option and a user-friendly message.
///	 - Providing UI components for currency selection, swapping currencies, and a custom numeric keypad.
///	 - Adapting the view layout based on the network state (online, offline with cache, offline with expired cache, or error).
///
///	 Use this view to present a user interface for currency conversion tasks within your SwiftUI application.
struct CurrencyConverterView: View {
	
	@StateObject var viewModel = CurrencyConverterViewModel()
	@State private var showingFromPicker = false
	@State private var showingToPicker = false
	
// MARK: - Offline Banner
	
	private var offlineBanner: some View {
		HStack {
			Image(systemName: "wifi.slash")
			Text("Offline Mode - Using Cached Data")
			Button("Retry") {
				viewModel.fetchExchangeRates()
			}
		}
		.padding()
		.background(Color(.systemYellow).opacity(0.2))
	}
	
// MARK: - Error View
	
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
