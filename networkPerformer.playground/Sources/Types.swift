import Foundation

public typealias AsyncOperation = () async -> OperationResult
public typealias OperationResult = Result<OperationType, OperationError>

public enum OperationType {
    case timeout, cancellation, networkMonitor, networkTask
}

public enum OperationError: Error {
    case genericError
}

public struct AsyncThrowingTask {
    private let operation: () async throws -> OperationResult
    
    init(operation: @escaping () async throws -> OperationResult) {
        self.operation = operation
    }
    
    func execute() async throws -> OperationResult {
        try await operation()
    }
}
