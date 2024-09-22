//
//  Types.swift
//  imageDownloader
//
//  Created by nicolo.pasini on 22/09/24.
//

import Foundation

typealias AsyncOperation = () async -> OperationResult
typealias OperationResult = Result<OperationType, OperationError>

enum OperationType {
    case timeout, cancellation, networkMonitor, networkTask
}

enum OperationError: Error {
    case genericError
}

struct AsyncThrowingTask {
    private let operation: () async throws -> OperationResult
    
    init(operation: @escaping () async throws -> OperationResult) {
        self.operation = operation
    }
    
    func execute() async throws -> OperationResult {
        try await operation()
    }
}

