import Foundation
import Network

public protocol NetworkMonitorProtocol {
    func isInternetConnectionAvailable() -> Bool
    func networkAvailabilityStream() -> AsyncStream<Bool>
}

public class NWNetworkMonitor: NetworkMonitorProtocol {
    private let monitor: NWPathMonitor
    
    public init() {
        monitor = NWPathMonitor()
    }
    
    public func networkAvailabilityStream() -> AsyncStream<Bool> {
        AsyncStream<Bool> { continuation in
            Task {
                for await path in monitor {
                    continuation.yield(path.status == .satisfied)
                }
                
                continuation.finish()
            }
        }
    }
    
    public func isInternetConnectionAvailable() -> Bool {
        monitor.currentPath.status == .satisfied
    }
}
