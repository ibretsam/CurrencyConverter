//
//  NetworkMonitor.swift
//  CurrencyConverter
//
//  Created by MasterBi on 14/01/2025.
//
import Foundation
import Network

/// Network connection state enumeration
///
/// # States
/// - online: Active internet connection
/// - offlineWithValidCache: No connection, using valid cached data
/// - offlineWithExpiredCache: No connection, cached data expired
/// - error: Error state with description
enum NetworkState {
	case online
	case offlineWithValidCache
	case offlineWithExpiredCache
	case error(String)
}

/// Monitors network connectivity changes
///
/// # Features
/// - Real-time connection monitoring
/// - Published connection state
/// - Background queue management
/// - Automatic state updates
///
/// # Usage Example
/// ```swift
/// @ObservedObject var monitor = NetworkMonitor.shared
/// if monitor.isConnected {
///     // Handle online state
/// }
/// ```
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
