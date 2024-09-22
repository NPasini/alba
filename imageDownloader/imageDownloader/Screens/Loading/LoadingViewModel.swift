//
//  LoadingViewModel.swift
//  imageDownloader
//
//  Created by nicolo.pasini on 22/09/24.
//

import SwiftUI

final class LoadingViewModel: ObservableObject {
    private let networkMonitor: NetworkMonitorProtocol
    private let networkPerformer: NetworkOperationPerformer
    
    @Published var isNetworkAvailable: Bool
    
    init(networkMonitor: NetworkMonitorProtocol, networkPerformer: NetworkOperationPerformer) {
        self.networkMonitor = networkMonitor
        self.networkPerformer = networkPerformer
        isNetworkAvailable = networkMonitor.isInternetConnectionAvailable()
    }
    
    func startMonitoringForNetworkAvailability() async {
        for await availability in self.networkMonitor.networkAvailabilityStream() {
            if availability { break }
        }
    }
}
