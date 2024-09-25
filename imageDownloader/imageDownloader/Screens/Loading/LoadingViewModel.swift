//
//  LoadingViewModel.swift
//  imageDownloader
//
//  Created by nicolo.pasini on 22/09/24.
//

import SwiftUI

@Observable 
final class LoadingViewModel {
    private var isNetworkAvailable: Bool
    private var hasNetworkLabelThresoldTimePassed: Bool = false
    
    private let downloadTimeout: TimeInterval
    private let httpClient: HTTPClientProtocol
    private let onDownloadCompleted: (Data?) -> Void
    private let networkAvailableTimeout: TimeInterval
    private let networkMonitor: NetworkMonitorProtocol
    private let networkPerformer: NetworkOperationPerformer
    
    var shouldDisplayNetworkNotAvailable: Bool {
        !isNetworkAvailable && hasNetworkLabelThresoldTimePassed
    }
    
    let notAvailableNetworkText = "Network not available 😢"
    
    init(httpClient: HTTPClientProtocol, networkMonitor: NetworkMonitorProtocol, networkPerformer: NetworkOperationPerformer, networkAvailableTimeout: TimeInterval = networkLabelTreshold, downloadTimeout: TimeInterval = networkOperationTimeout, onDownloadCompleted: @escaping (Data?) -> Void) {
        self.httpClient = httpClient
        self.networkMonitor = networkMonitor
        self.downloadTimeout = downloadTimeout
        self.networkPerformer = networkPerformer
        self.onDownloadCompleted = onDownloadCompleted
        self.networkAvailableTimeout = networkAvailableTimeout
        isNetworkAvailable = networkMonitor.isInternetConnectionAvailable()
    }
    
    func onAppear() {
        monitoringForNetworkAvailability()
        startNetworkThresholdTimer()
        fetchImage()
    }
}

private extension LoadingViewModel {
    static let networkLabelTreshold: TimeInterval = 0.5
    static let networkOperationTimeout: TimeInterval = 2
    
    func startNetworkThresholdTimer() {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(networkAvailableTimeout) * 1_000_000_000)
            hasNetworkLabelThresoldTimePassed = true
        }
    }
    
    func monitoringForNetworkAvailability() {
        Task {
            for await availability in self.networkMonitor.networkAvailabilityStream() {
                isNetworkAvailable = availability
            }
        }
    }
    
    func fetchImage() {
        Task {
            let result = await networkPerformer.perform(withinSeconds: downloadTimeout) { [weak self] in
                guard let self else { return .failure(.genericError) }
                
                do {
                    guard let url = ImageEndpoint.getImage.url() else { return .failure(.genericError) }
                    let downloadedImageData = try await httpClient.getData(from: url)
                    return .success(.imageDownload(data: downloadedImageData))
                } catch {
                    return .failure(.genericError)
                }
            }
            
            handleFetchResult(result)
        }
    }
    
    func handleFetchResult(_ result: OperationResult) {
        if case let .success(.imageDownload(imageData)) = result {
            onDownloadCompleted(imageData)
        }
    }
}
