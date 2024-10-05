import Foundation

public final class NetworkOperationPerformer {
    private typealias TaskResult = Result<TaskType, TaskError>
    
    private enum TaskType {
        case timer, networkMonitor
    }
    
    private let networkMonitor: NetworkMonitorProtocol
    private var cancelContinuation: AsyncStream<Bool>.Continuation?
    
    public init(networkMonitor: NetworkMonitorProtocol = NWNetworkMonitor()) {
        self.networkMonitor = networkMonitor
    }
    
    /// Attempts to perform a network operation within the given timeout.
    ///
    /// Use this method to perform a network operation when the network connection is available and, in case the network is initially not available, to wait for network availability until specified timeout.
    /// - If no network is available, the given closure is not invoked;
    /// - If the network is initially available, the given closure is invoked;
    /// - If the network is initially not available but becomes available within the given timeout duration, the given closure is invoked;
    /// - If the network is initially not available and becomes available only after the given timeout duration, the given closure is not invoked.
    ///
    /// - Parameters:
    ///     - `timeout`: The timeout after which stop monitoring for network availability and the closure is not executed.
    ///     - `networkOperation`: The closure to execute.
    /// - Returns: An `OperationResult` which contains `failure` in case the closure is not executed because of the timeout or the closure execution returns an error, `success` in case the closure is executed successfully.
    public func perform<OperationResult>(withinSeconds timeout: TimeInterval, networkOperation: () async -> OperationResult) async -> Result<OperationResult, TaskError> {
        guard networkMonitor.isInternetConnectionAvailable() else {
            return await waitNetworkAvailability(withTimeout: timeout, andPerformOperation: networkOperation)
        }
        
        return .success(await networkOperation())
    }
    
    /// Cancel the execution of the launched operation.
    /// - If the operation is waiting network connection to be executed the `NetworkOperationPerformer` will stop monitoring for network availability and the given closure will not be invoked;
    /// - If the operation has been started it will continue to execute until it completes;
    public func cancelTask() {
        cancelContinuation?.yield(true)
    }
}

extension NetworkOperationPerformer {
    func waitNetworkAvailability<OperationResult>(withTimeout timeout: TimeInterval, andPerformOperation networkOperation: () async -> OperationResult) async -> Result<OperationResult, TaskError> {
        let result = await Task.race(firstCompleted: [
            timerTask(withTimeout: timeout),
            monitorForNetworkAvailableTask()
        ])
        
        if case .success(.networkMonitor) = result {
            return .success(await networkOperation())
        } else {
            return .failure(.genericError)
        }
    }
    
    private func timerTask(withTimeout timeout: TimeInterval) -> AsyncTask<TaskResult> {
        AsyncTask {
            do {
                try await Task.sleep(nanoseconds: UInt64(timeout) * 1_000_000_000)
                return .success(.timer)
            } catch {
                return .failure(.genericError)
            }
        }
    }
    
    private func monitorForNetworkAvailableTask() -> AsyncTask<TaskResult> {
        AsyncTask {
            for await availability in self.networkMonitor.networkAvailabilityStream() {
                if availability { break }
            }
            
            guard !Task.isCancelled else {
                return .failure(.genericError)
            }
            
            return .success(.networkMonitor)
        }
    }
    
    func cancelOperationTask() -> AsyncTask {
        AsyncTask {
            for await isCancelled in self.listenForCancelEvent() {
                if isCancelled { break }
            }
            
            guard !Task.isCancelled else {
                return .failure(.genericError)
            }
            
            return .success(.cancellation)
        }
    }
    
    func listenForCancelEvent() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            self.cancelContinuation = continuation
        }
    }
}
