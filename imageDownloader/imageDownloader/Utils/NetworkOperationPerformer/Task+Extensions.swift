//
//  Task+Extensions.swift
//  imageDownloader
//
//  Created by nicolo.pasini on 22/09/24.
//

extension Task where Success == Never, Failure == Never {
    static func race<OperationResult>(firstCompleted tasks: [AsyncTask<OperationResult>]) async -> OperationResult {
        await withTaskGroup(of: OperationResult.self) { group -> OperationResult in
            for task in tasks {
                group.addTask() {
                    await task.execute()
                }
            }
            
            defer {
                group.cancelAll()
            }
            
            if let firstToComplete = await group.next() {
                return firstToComplete
            } else {
                fatalError("Expecting at least 1 task")
            }
        }
    }
}
