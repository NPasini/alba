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
    
    private var isNetworkAvailable: Bool
    private var hasNetworkLabelThresoldTimePassed: Bool = false
    
    private let downloadTimeout: TimeInterval
    private let httpClient: HTTPClientProtocol
    private let onDownloadCompleted: (Data?) -> Void
    private let networkAvailableTimeout: TimeInterval
    private let networkMonitor: NetworkMonitorProtocol
    private let networkPerformer: NetworkOperationPerformerProtocol
    
    var shouldDisplayNetworkNotAvailable: Bool {
        !isNetworkAvailable && hasNetworkLabelThresoldTimePassed
    }
    
    let notAvailableNetworkText = "Network not available 😢"
    
    init(httpClient: HTTPClientProtocol, networkMonitor: NetworkMonitorProtocol, networkPerformer: NetworkOperationPerformerProtocol, networkAvailableTimeout: TimeInterval = networkLabelTreshold, downloadTimeout: TimeInterval = networkOperationTimeout, onDownloadCompleted: @escaping (Data?) -> Void) {
        self.httpClient = httpClient
        self.networkMonitor = networkMonitor
        self.downloadTimeout = downloadTimeout
        self.networkPerformer = networkPerformer
        self.onDownloadCompleted = onDownloadCompleted
        self.networkAvailableTimeout = networkAvailableTimeout
        isNetworkAvailable = networkMonitor.isInternetConnectionAvailable()
    }
    
    func onAppear() async {
        await withTaskGroup(of: TaskResult.self) { group in
            group.addTask { await self.monitoringForNetworkAvailability() }
            group.addTask { await self.startNetworkThresholdTimer() }
            group.addTask { await self.fetchImage() }
            
            defer {
                group.cancelAll()
            }
            
            while let taskResult = await group.next() {
                if isResultHandled(taskResult) { return }
            }
        }
    }
}

private extension LoadingViewModel {
    static let networkLabelTreshold: TimeInterval = 0.5
    static let networkOperationTimeout: TimeInterval = 2
    
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
        let result = await networkPerformer.perform(withinSeconds: downloadTimeout) { [weak self] () async -> Data? in
            guard let self,
                  let url = ImageEndpoint.getImage.url(),
                  let data = try? await httpClient.getData(from: url) else { return nil }
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
            onDownloadCompleted(imageData)
            return true
        } else if case .failure(.networkOperationNotPerformed) = result {
            onDownloadCompleted(nil)
            return true
        }

        return false
    }
}
