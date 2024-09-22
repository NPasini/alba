import Foundation

public final class NetworkOperationPerformer {
    private var networkOperation: AsyncOperation?
    private let networkMonitor: NetworkMonitorProtocol
    private var cancelContinuation: AsyncStream<Bool>.Continuation?
    
    public init(networkMonitor: NetworkMonitorProtocol = NetworkMonitorMock.neverAvailable) {
        self.networkMonitor = networkMonitor
    }
    
    public func perform(withinSeconds timeout: TimeInterval, networkOperation: @escaping AsyncOperation) async -> OperationResult {
        self.networkOperation = networkOperation
        
        guard networkMonitor.isInternetConnectionAvailable() else {
            return await waitNetworkAvailability(withTimeout: timeout, andPerformOperation: networkOperation)
        }
        
        return await networkOperation()
    }
    
    public func cancelTask() {
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
            return .success(.timeout)
        }
    }
    
    private func monitorForNetworkAvailableTask() -> AsyncThrowingTask {
        AsyncThrowingTask {
            for await availability in self.networkMonitor.networkAvailabilityStream() {
                if availability { break }
            }
            
            guard !Task.isCancelled else {
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
                return .failure(.genericError)
            }
            
            return .success(.cancellation)
        }
    }
    
    private func listenForCancelEvent() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            self.cancelContinuation = continuation
        }
    }
}
