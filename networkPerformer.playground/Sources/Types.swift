import Foundation

public typealias AsyncOperation = () async -> OperationResult
public typealias OperationResult = Result<Void, OperationError>

public enum OperationError: Error {
    case internalError, networkNotAvailable
}
