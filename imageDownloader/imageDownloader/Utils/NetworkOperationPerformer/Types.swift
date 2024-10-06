//
//  Types.swift
//  imageDownloader
//
//  Created by nicolo.pasini on 22/09/24.
//

import Foundation

enum NetworkOperationError: Error {
    case genericError, networkOperationNotPerformed
}

struct AsyncTask<OperationResult> {
    private let operation: () async -> OperationResult
    
    init(operation: @escaping () async -> OperationResult) {
        self.operation = operation
    }
    
    func execute() async -> OperationResult {
        await operation()
    }
}
