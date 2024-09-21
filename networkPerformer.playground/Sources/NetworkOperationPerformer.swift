import Foundation

public class NetworkOperationPerformer {
    private let networkMonitor: NetworkMonitorProtocol
    
    public init(networkMonitor: NetworkMonitorProtocol = NWNetworkMonitor()) {
        self.networkMonitor = networkMonitor
    }
    
    public func perform(withinSeconds timeout: TimeInterval, networkOperation: @escaping AsyncOperation) async -> OperationResult {
        guard networkMonitor.isInternetConnectionAvailable() else {
            print("Test - Network not available, start monitoring network")
            return await waitNetworkAvailability(withTimeout: timeout, andPerformOperation: networkOperation)
        }
        
        print("Test - Network available, invoke closure")
        return await networkOperation()
    }
}

private extension NetworkOperationPerformer {
    private func waitNetworkAvailability(withTimeout timeout: TimeInterval, andPerformOperation networkOperation: @escaping AsyncOperation) async -> OperationResult {
        do {
            try await Task.race(firstCompleted: [
                timerTask(withTimeout: timeout),
                monitorForNetworkAvailableTask()
            ])
            print("Test - Running operation")
            return await networkOperation()
        } catch {
            return .failure(.internalError)
        }
    }
    
    private func timerTask(withTimeout timeout: TimeInterval) -> AsyncThrowingTask {
        AsyncThrowingTask {
            try await Task.sleep(nanoseconds: UInt64(timeout) * 1_000_000_000)
            print("Test - Timer rings")
            throw OperationError.timeout
        }
    }
    
    private func monitorForNetworkAvailableTask() -> AsyncThrowingTask {
        AsyncThrowingTask {
            for await availability in self.networkMonitor.networkAvailabilityStream() {
                print("Test - Network availability \(availability)")
                if availability {
                    print("Test - breaking")
                    break
                }
            }
            
            guard !Task.isCancelled else {
                print("Test - Task has been cancelled")
                return
            }
        }
    }
    
    private func cancelOperation() {
        print("Test - Cancel network operation")
    }
}
