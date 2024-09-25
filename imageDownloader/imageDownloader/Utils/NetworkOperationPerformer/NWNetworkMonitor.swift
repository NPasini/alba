//
//  NWNetworkMonitor.swift
//  imageDownloader
//
//  Created by nicolo.pasini on 22/09/24.
//

import Foundation
import Network

protocol NetworkMonitorProtocol {
    func isInternetConnectionAvailable() -> Bool
    func networkAvailabilityStream() -> AsyncStream<Bool>
}

final class NWNetworkMonitor: NetworkMonitorProtocol {
    private let monitor: NWPathMonitor
    
    init() {
        monitor = NWPathMonitor()
    }
    
    func networkAvailabilityStream() -> AsyncStream<Bool> {
        AsyncStream<Bool> { continuation in
            let task = Task {
                for await path in monitor {
                    continuation.yield(path.status == .satisfied)
                    if path.status == .satisfied {
                        continuation.finish()
                    }
                }
            }
            
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
    
    func isInternetConnectionAvailable() -> Bool {
        monitor.currentPath.status == .satisfied
    }
}
