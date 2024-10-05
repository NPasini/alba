import Foundation

public enum NetworkOperationError: Error {
    case genericError
}

public struct AsyncTask<OperationResult> {
    private let operation: () async -> OperationResult
    
    init(operation: @escaping () async -> OperationResult) {
        self.operation = operation
    }
    
    func execute() async -> OperationResult {
        await operation()
    }
}
