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
    private var continuations = [AsyncStream<Bool>.Continuation]()
    
    init() {
        monitor = NWPathMonitor()
    }
    
    deinit {
        continuations.forEach { $0.finish() }
    }
    
    func networkAvailabilityStream() -> AsyncStream<Bool> {
        AsyncStream<Bool> { continuation in
            let task = Task {
                for await path in monitor {
                    if path.status == .satisfied {
                        print("Test - network available")
                    }
                    continuation.yield(path.status == .satisfied)
                }
            }
            
            continuation.onTermination = { [task] _ in
                task.cancel()
            }
            
            continuations.append(continuation)
        }
    }
    
    func isInternetConnectionAvailable() -> Bool {
        monitor.currentPath.status == .satisfied
    }
}
