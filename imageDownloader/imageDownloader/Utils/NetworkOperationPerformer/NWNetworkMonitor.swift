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
    private var continuation: AsyncStream<Bool>.Continuation?
    
    init() {
        monitor = NWPathMonitor()
    }
    
    deinit {
        continuation?.finish()
    }
    
    func networkAvailabilityStream() -> AsyncStream<Bool> {
        AsyncStream<Bool> { continuation in
            let task = Task {
                for await path in monitor {
                    continuation.yield(path.status == .satisfied)
                }
            }
            
            continuation.onTermination = { [task] _ in
                task.cancel()
            }
            
            self.continuation = continuation
        }
    }
    
    func isInternetConnectionAvailable() -> Bool {
        monitor.currentPath.status == .satisfied
    }
}
