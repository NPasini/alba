import Foundation

public extension Task where Success == Never, Failure == Never {
    static func race(firstCompleted tasks: [AsyncThrowingTask]) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for task in tasks {
                group.addTask() {
                    try await task.execute()
                }
            }
            
            defer {
                print("Test - Cancelling pending task")
                group.cancelAll()
            }
            
            if let firstToComplete = try await group.next() {
                return firstToComplete
            } else {
                // There will be at least 1 task.
                fatalError("At least 1 task should be scheduled.")
            }
        }
    }
}
