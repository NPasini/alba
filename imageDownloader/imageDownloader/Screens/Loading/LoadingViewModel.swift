//
//  LoadingViewModel.swift
//  imageDownloader
//
//  Created by nicolo.pasini on 22/09/24.
//

import SwiftUI

@Observable 
final class LoadingViewModel {
    private var timer: Timer? = nil
    private var isNetworkAvailable: Bool
    private var haveFiveSecondsPassed: Bool = false
    
    private let downloadTimeout: TimeInterval
    private let httpClient: HTTPClientProtocol
    private let onDownloadCompleted: (Data?) -> Void
    private let networkAvailableTimeout: TimeInterval
    private let networkMonitor: NetworkMonitorProtocol
    private let networkPerformer: NetworkOperationPerformer
    
    var shouldDisplayNetworkNotAvailable: Bool {
        !isNetworkAvailable && haveFiveSecondsPassed
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
        startNetworkTimer()
        startFetchingImage()
        
        Task {
            await monitoringForNetworkAvailability() // Stoppare quando la view viene nascosta
        }
    }
}

private extension LoadingViewModel {
    static let networkLabelTreshold: TimeInterval = 0.5
    static let networkOperationTimeout: TimeInterval = 2
    
    func startNetworkTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: networkAvailableTimeout, repeats: false) { [self] _ in
            haveFiveSecondsPassed = true
            timer = nil
        }
    }
    
    func monitoringForNetworkAvailability() async {
        for await availability in self.networkMonitor.networkAvailabilityStream() {
            isNetworkAvailable = availability
        }
    }
    
    func startFetchingImage() {
        Task {
            var downloadedImageData: Data?
            await networkPerformer.perform(withinSeconds: downloadTimeout) { [weak self] in
                guard let self else { return .failure(.genericError) }
                
                do {
                    guard let url = ImageEndpoint.getImage.url() else { return .failure(.genericError) }
                    downloadedImageData = try await httpClient.getData(from: url)
                    return .success(.imageDownload)
                } catch {
                    print("Test - Error: \(error)")
                    return .failure(.genericError)
                }
            }
            
            print("Test - Displaying triggering new screen")
            onDownloadCompleted(downloadedImageData)
        }
    }
}
