import Foundation
import Network

public protocol NetworkMonitorProtocol {
    func isInternetConnectionAvailable() -> Bool
    func networkAvailabilityStream() -> AsyncStream<Bool>
}

public final class NWNetworkMonitor: NetworkMonitorProtocol {
    private let monitor: NWPathMonitor
    private var continuation: AsyncStream<Bool>.Continuation?
    
    public init() {
        monitor = NWPathMonitor()
    }
    
    deinit {
        continuation?.finish()
    }
    
    public func networkAvailabilityStream() -> AsyncStream<Bool> {
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
    
    public func isInternetConnectionAvailable() -> Bool {
        monitor.currentPath.status == .satisfied
    }
}
