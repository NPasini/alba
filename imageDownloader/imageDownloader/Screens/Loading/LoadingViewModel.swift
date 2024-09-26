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
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.monitoringForNetworkAvailability() }
            group.addTask { await self.startNetworkThresholdTimer() }
            group.addTask { await self.fetchImage() }
        }
    }
}

private extension LoadingViewModel {
    static let networkLabelTreshold: TimeInterval = 0.5
    static let networkOperationTimeout: TimeInterval = 2
    
    func startNetworkThresholdTimer() async {
        try? await Task.sleep(nanoseconds: UInt64(networkAvailableTimeout) * 1_000_000_000)
        hasNetworkLabelThresoldTimePassed = true
    }
    
    func monitoringForNetworkAvailability() async {
        for await availability in networkMonitor.networkAvailabilityStream() {
            isNetworkAvailable = availability
        }
    }
    
    func fetchImage() async {
        var downloadedImageData: Data?
        await networkPerformer.perform(withinSeconds: downloadTimeout) { [weak self] in
            guard let self else { return .failure(.genericError) }
            
            do {
                guard let url = ImageEndpoint.getImage.url() else { return .failure(.genericError) }
                downloadedImageData = try await httpClient.getData(from: url)
                return .success(.imageDownload)
            } catch {
                return .failure(.genericError)
            }
        }
        
        onDownloadCompleted(downloadedImageData)
    }
}
