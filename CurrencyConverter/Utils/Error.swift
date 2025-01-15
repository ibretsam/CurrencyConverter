//
//  Error.swift
//  CurrencyConverter
//
//  Created by MasterBi on 12/01/2025.
//
import Foundation

enum NetworkError: LocalizedError {
	case noInternet
	case invalidURL
	case invalidResponse
	case invalidData
	case noData
	case networkError(Error)
	case expired
	
	var errorDescription: String? {
		switch self {
			case .noInternet: return "No internet connection"
			case .invalidURL: return "Invalid URL"
			case .invalidResponse: return "Server returned an invalid response"
			case .invalidData: return "Could not parse server response"
			case .noData: return "Server returned no data"
			case .networkError(let error): return error.localizedDescription
			case .expired: return "Exchange rates data has expired"
		}
	}
}

enum DataError: LocalizedError {
	case invalidData
	case invalidCurrency
	
	var errorDescription: String? {
		switch self {
			case .invalidData: return "The data is invalid or corrupted"
			case .invalidCurrency: return "The currency is invalid"
		}
	}
}
