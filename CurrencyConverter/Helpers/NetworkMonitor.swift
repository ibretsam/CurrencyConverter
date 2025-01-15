//
//  NetworkMonitor.swift
//  CurrencyConverter
//
//  Created by MasterBi on 14/01/2025.
//
import Foundation
import Network

enum NetworkState {
	case online
	case offlineWithValidCache
	case offlineWithExpiredCache
	case error(String)
}

class NetworkMonitor: ObservableObject {
	static let shared = NetworkMonitor()
	@Published var isConnected = true
	private let monitor = NWPathMonitor()
	
	private init() {
		monitor.pathUpdateHandler = { [weak self] path in
			DispatchQueue.main.async {
				self?.isConnected = path.status == .satisfied
				print("Network state changed: \(path.status == .satisfied ? "Connected" : "Disconnected")")
			}
		}
		let queue = DispatchQueue(label: "NetworkMonitor")
		monitor.start(queue: queue)
	}
}
