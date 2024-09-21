import Foundation

//public typealias AsyncThrowingTask = () async throws -> Void
public typealias AsyncOperation = () async -> OperationResult
public typealias OperationResult = Result<Void, OperationError>

public enum OperationError: Error {
    case internalError, timeout
}

public struct AsyncThrowingTask {
    private let operation: () async throws -> Void
    
    init(operation: @escaping () async throws -> Void) {
        self.operation = operation
    }
    
    func execute() async throws {
        try await operation()
    }
}
