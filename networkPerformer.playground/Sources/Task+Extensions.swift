import Combine

public extension Task where Success == Never, Failure == Never {
    static func race(firstCompleted tasks: [AsyncThrowingTask]) async throws -> OperationResult {
        try await withThrowingTaskGroup(of: OperationResult.self) { group -> OperationResult in
            for task in tasks {
                group.addTask() {
                    try await task.execute()
                }
            }
            
            defer {
                group.cancelAll()
            }
            
            if let firstToComplete = try await group.next() {
                return firstToComplete
            } else {
                fatalError("Expecting at least 1 task")
            }
        }
    }
}
