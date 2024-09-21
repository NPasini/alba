import Foundation

public class NetworkOperationPerformer {
    private var networkOperation: AsyncOperation?
    private let networkMonitor: NetworkMonitorProtocol
    private var cancelContinuation: AsyncStream<Bool>.Continuation?
    
    public init(networkMonitor: NetworkMonitorProtocol = NWNetworkMonitor()) {
        self.networkMonitor = networkMonitor
    }
    
    public func perform(withinSeconds timeout: TimeInterval, networkOperation: @escaping AsyncOperation) async -> OperationResult {
        self.networkOperation = networkOperation
        
        guard networkMonitor.isInternetConnectionAvailable() else {
            print("Test - Network not available, start monitoring network")
            return await waitNetworkAvailability(withTimeout: timeout, andPerformOperation: networkOperation)
        }
        
        print("Test - Network available, invoke closure")
        return await networkOperation()
    }
    
    public func cancelTask() {
        print("Test - Canelling operation")
        cancelContinuation?.yield(true)
    }
}

private extension NetworkOperationPerformer {
    private func waitNetworkAvailability(withTimeout timeout: TimeInterval, andPerformOperation networkOperation: @escaping AsyncOperation) async -> OperationResult {
        do {
            let result = try await Task.race(firstCompleted: [
                timerTask(withTimeout: timeout),
                monitorForNetworkAvailableTask(),
                cancelOperationTask()
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
    
    private func cancelOperationTask() -> AsyncThrowingTask {
        AsyncThrowingTask {
            for await isCancelled in self.listenForCancelEvent() {
                if isCancelled { break }
            }
            
            guard !Task.isCancelled else {
                print("Test - Task has been cancelled")
                return .failure(.genericError)
            }
            
            print("Test - Operation manually cancelled")
            return .success(.cancellation)
        }
    }
    
    private func listenForCancelEvent() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            self.cancelContinuation = continuation
        }
    }
}
