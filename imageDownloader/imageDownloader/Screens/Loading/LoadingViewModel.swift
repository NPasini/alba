//
//  LoadingViewModel.swift
//  imageDownloader
//
//  Created by nicolo.pasini on 22/09/24.
//

import SwiftUI

@Observable 
final class LoadingViewModel {
    private typealias TaskResult = Result<TaskType, TaskError>
    
    private enum TaskError: Error {
        case genericError, networkOperationNotPerformed
    }
    
    private enum TaskType {
        case timer, networkMonitor, imageDownload(imageData: Data?)
    }
    
    private var counter = Counter()
    private var isNetworkAvailable: Bool
    private var hasNetworkLabelThresoldTimePassed: Bool = false
    
    private let downloadTimeout: TimeInterval
    private let httpClient: HTTPClientProtocol
    private let onLoadingCompleted: (Data?) -> Void
    private let networkAvailableTimeout: TimeInterval
    private let networkMonitor: NetworkMonitorProtocol
    private let networkPerformer: NetworkOperationPerformerProtocol
    
    var shouldDisplayNetworkNotAvailable: Bool {
        !isNetworkAvailable && hasNetworkLabelThresoldTimePassed
    }
    
    let notAvailableNetworkText = "Network not available 😢"
    
    init(httpClient: HTTPClientProtocol, networkMonitor: NetworkMonitorProtocol, networkPerformer: NetworkOperationPerformerProtocol, networkAvailableTimeout: TimeInterval = networkLabelTreshold, downloadTimeout: TimeInterval = networkOperationTimeout, onLoadingCompleted: @escaping (Data?) -> Void) {
        self.httpClient = httpClient
        self.networkMonitor = networkMonitor
        self.downloadTimeout = downloadTimeout
        self.networkPerformer = networkPerformer
        self.onLoadingCompleted = onLoadingCompleted
        self.networkAvailableTimeout = networkAvailableTimeout
        isNetworkAvailable = networkMonitor.isInternetConnectionAvailable()
    }
    
    func onAppear() async {
        await withTaskGroup(of: TaskResult.self) { group in
//            group.addTask { await self.monitoringForNetworkAvailability() }
//            group.addTask { await self.startNetworkThresholdTimer() }
            group.addTask { await self.fetchImage() }
            group.addTask { await self.fetchImage() }
            group.addTask {
                try! await Task.sleep(nanoseconds: 2_000_000_000)
                return await self.fetchImage()
            }
            
            var results = [TaskResult]()
                for await result in group {
                    results.append(result)
                }
            print(results)
            
            defer {
                group.cancelAll()
            }
            
//            while let taskResult = await group.next() {
//                if isResultHandled(taskResult) { return }
//            }
        }
    }
}

private extension LoadingViewModel {
    static let networkLabelTreshold: TimeInterval = 0.5
    static let networkOperationTimeout: TimeInterval = 5
    
    private func startNetworkThresholdTimer() async -> TaskResult {
        try? await Task.sleep(nanoseconds: UInt64(networkAvailableTimeout) * 1_000_000_000)
        hasNetworkLabelThresoldTimePassed = true
        return .success(.timer)
    }
    
    private func monitoringForNetworkAvailability() async -> TaskResult {
        for await availability in networkMonitor.networkAvailabilityStream() {
            isNetworkAvailable = availability
        }
        
        return .success(.networkMonitor)
    }
    
    private func fetchImage() async -> TaskResult {
        let value = await counter.value
        await counter.increaseValue()
        let result = await networkPerformer.perform(task: value, withinSeconds: downloadTimeout) { [weak self] () async -> Data? in
            print("Test - execute operation \(value)")
            guard let self,
                  let url = ImageEndpoint.getImage.url(),
                  let data = try? await httpClient.getData(from: url) else {
                return nil
            }
            return data
        }
        
        switch result {
        case let .success(data):
            return .success(.imageDownload(imageData: data))
        default:
            return .failure(.networkOperationNotPerformed)
        }
    }
    
    private func isResultHandled(_ result: TaskResult) -> Bool {
        if case let .success(.imageDownload(imageData)) = result {
            onLoadingCompleted(imageData)
            return true
        } else if case .failure(.networkOperationNotPerformed) = result {
            onLoadingCompleted(nil)
            return true
        }

        return false
    }
}

fileprivate actor Counter {
    var value: Int = 0
    
    func increaseValue() {
        value += 1
    }
}
