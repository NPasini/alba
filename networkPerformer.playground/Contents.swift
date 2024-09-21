import Foundation
import Network

public protocol NetworkMonitorProtocol {
    func waitForNetworkAvailable() async
    func isInternetConnectionAvailable() -> Bool
}

class NWNetworkMonitor: NetworkMonitorProtocol {
    func waitForNetworkAvailable() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
    }
    
    func isInternetConnectionAvailable() -> Bool {
        false
    }
}


