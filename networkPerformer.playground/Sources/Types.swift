import Foundation

public typealias AsyncOperation = () async -> OperationResult
public typealias AsyncIntOperation = (Int) async -> OperationResult
public typealias OperationResult = Result<OperationType, OperationError>

public enum OperationType {
    case timeout, cancellation, networkMonitor, networkTask
}

public enum OperationError: Error {
    case genericError
}

public struct AsyncTask {
    private let operation: () async -> OperationResult
    
    init(operation: @escaping () async -> OperationResult) {
        self.operation = operation
    }
    
    func execute() async -> OperationResult {
        await operation()
    }
}
