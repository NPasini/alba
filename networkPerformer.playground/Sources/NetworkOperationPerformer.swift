import Foundation

public class NetworkOperationPerformer {
    private let networkMonitor: NetworkMonitorProtocol
    
    public init(networkMonitor: NetworkMonitorProtocol = NetworkMonitor()) {
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
            let result = try await Task.race(firstCompleted: [
                timerTask(withTimeout: timeout),
                monitorForNetworkAvailableTask()
            ])
            
            if case let .success(operation) = result, operation == .networkMonitor {
                print("Test - Running operation")
                return await networkOperation()
            } else {
                return .failure(.genericError)
            }            
        } catch {
            return .failure(.genericError)
        }
    }
    
    private func timerTask(withTimeout timeout: TimeInterval) -> AsyncThrowingTask {
        AsyncThrowingTask {
            try await Task.sleep(nanoseconds: UInt64(timeout) * 1_000_000_000)
            print("Test - Timer rings")
            return .success(.timeout)
        }
    }
    
    private func monitorForNetworkAvailableTask() -> AsyncThrowingTask {
        AsyncThrowingTask {
            for await availability in self.networkMonitor.networkAvailabilityStream() {
                print("Test - Network availability \(availability)")
                if availability { break }
            }
            
            guard !Task.isCancelled else {
                print("Test - Task has been cancelled")
                return .failure(.genericError)
            }
            
            return .success(.networkMonitor)
        }
    }
    
    private func cancelOperation() {
        print("Test - Cancel network operation")
    }
}
