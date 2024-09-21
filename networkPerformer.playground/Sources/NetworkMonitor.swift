import Foundation

public protocol NetworkMonitorProtocol {
    func waitForNetworkAvailable() async
    func isInternetConnectionAvailable() -> Bool
}

public class NWNetworkMonitor: NetworkMonitorProtocol {
    public init() {}
    
    public func waitForNetworkAvailable() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
    }
    
    public func isInternetConnectionAvailable() -> Bool {
        false
    }
}
