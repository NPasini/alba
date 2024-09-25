//
//  NetworkOperationPerformer.swift
//  imageDownloader
//
//  Created by nicolo.pasini on 22/09/24.
//

import Foundation

protocol NetworkOperationPerformerProtocol {
    func cancelTask()
    func perform(withinSeconds timeout: TimeInterval, networkOperation: @escaping AsyncOperation) async -> OperationResult
}

final class NetworkOperationPerformer {
    private var networkOperation: AsyncOperation?
    private let networkMonitor: NetworkMonitorProtocol
    private var cancelContinuation: AsyncStream<Bool>.Continuation?
    
    init(networkMonitor: NetworkMonitorProtocol) {
        self.networkMonitor = networkMonitor
    }
    
    /// Attempts to perform a network operation within the given timeout.
    ///
    /// Use this method to perform a netowrk operation when the network connection is available.
    /// - If no network is available, the given closure is not invoked;
    /// - If the network is initially available, the given closure is invoked;
    /// - If the network is initially not available but becomes available within the given timeout duration, the given closure is invoked;
    /// - If the network is initially not available and becomes available only after the given timeout duration, the given closure is not invoked.
    ///
    /// - Parameters:
    ///     - `timeout`: The timeout after which the closure is not executed.
    ///     - `networkOperation`: The closure to execute.
    /// - Returns: An `OperationResult` which contains `failure` in case the the closure is not executed because of the timeout or the closure is executing returning an error, `success` in case the closure is executed successfully.
    @discardableResult
    func perform(withinSeconds timeout: TimeInterval, networkOperation: @escaping AsyncOperation) async -> OperationResult {
        self.networkOperation = networkOperation
        
        guard networkMonitor.isInternetConnectionAvailable() else {
            return await waitNetworkAvailability(withTimeout: timeout, andPerformOperation: networkOperation)
        }
        
        return await networkOperation()
    }
    
    /// Cancel the execution of the launched operation.
    /// - If the operation is waiting network connection to be executed the `NetworkOperationPerformer` will stop monitoring for network availability and the given closure will not be invoked;
    /// - If the operation has been started it will continue to execute until it completes;
    func cancelTask() {
        cancelContinuation?.yield(true)
    }
}

private extension NetworkOperationPerformer {
    func waitNetworkAvailability(withTimeout timeout: TimeInterval, andPerformOperation networkOperation: @escaping AsyncOperation) async -> OperationResult {
        do {
            let result = try await Task.race(firstCompleted: [
                timerTask(withTimeout: timeout),
                monitorForNetworkAvailableTask(),
                cancelOperationTask()
            ])
            
            if case .success(.networkMonitor) = result {
                return await networkOperation()
            } else {
                return .failure(.genericError)
            }
        } catch {
            return .failure(.genericError)
        }
    }
    
    func timerTask(withTimeout timeout: TimeInterval) -> AsyncThrowingTask {
        AsyncThrowingTask {
            try await Task.sleep(nanoseconds: UInt64(timeout) * 1_000_000_000)
            return .success(.timeout)
        }
    }
    
    func monitorForNetworkAvailableTask() -> AsyncThrowingTask {
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
    
    func cancelOperationTask() -> AsyncThrowingTask {
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
    
    func listenForCancelEvent() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            self.cancelContinuation = continuation
        }
    }
}

