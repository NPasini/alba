//
//  Types.swift
//  imageDownloader
//
//  Created by nicolo.pasini on 22/09/24.
//

import Foundation

typealias AsyncOperation = () async -> OperationResult
typealias OperationResult = Result<OperationType, OperationError>

enum OperationType: Equatable {
    case timeout, cancellation, networkMonitor, networkTask, imageDownload(data: Data)
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

