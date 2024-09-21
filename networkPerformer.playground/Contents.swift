import Foundation
import PlaygroundSupport
import networkPerformer_Sources

PlaygroundPage.current.needsIndefiniteExecution = true

class NetworkOperationPerformer {
    private var timer: Timer?
    private let networkMonitor: NetworkMonitorProtocol
    
    init(networkMonitor: NetworkMonitorProtocol = NWNetworkMonitor()) {
        self.networkMonitor = networkMonitor
    }
    
    func perform(withinSeconds timeout: TimeInterval, networkOperation: @escaping AsyncOperation) async -> OperationResult {
        guard networkMonitor.isInternetConnectionAvailable() else {
            // Network not Available -> Start monitoring for network
            print("Wait for network")
            return .failure(.internalError)
        }
        
        // Network Available -> Invoke closure
        return await networkOperation()
    }
}

let networkOperationClosure: AsyncOperation = {
    // Long-lasting network operation.
    print("Test - Running operation")
    return .success(())
}

print("Test - Start task")
let result = await NetworkOperationPerformer().perform(withinSeconds: 3) {
    return await networkOperationClosure()
}

PlaygroundPage.current.finishExecution()
