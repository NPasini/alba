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
    private let networkAvailableTimeout: TimeInterval
    private let networkMonitor: NetworkMonitorProtocol
    private let networkPerformer: NetworkOperationPerformer
    
    
    var shouldDisplayNetworkNotAvailable: Bool {
        !isNetworkAvailable && haveFiveSecondsPassed
    }
    
    init(networkMonitor: NetworkMonitorProtocol, networkPerformer: NetworkOperationPerformer, networkAvailableTimeout: TimeInterval = networkLabelTreshold, downloadTimeout: TimeInterval = networkOperationTimeout) {
        self.networkMonitor = networkMonitor
        self.downloadTimeout = downloadTimeout
        self.networkPerformer = networkPerformer
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
        }
    }
}
