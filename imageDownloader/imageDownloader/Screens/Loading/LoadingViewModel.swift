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
    
    private let router: Router
    private let urlSession: URLSession
    private let downloadTimeout: TimeInterval
    private let networkAvailableTimeout: TimeInterval
    private let networkMonitor: NetworkMonitorProtocol
    private let networkPerformer: NetworkOperationPerformer
    
    var shouldDisplayNetworkNotAvailable: Bool {
        !isNetworkAvailable && haveFiveSecondsPassed
    }
    
    init(urlSession: URLSession = .shared, router: Router, networkMonitor: NetworkMonitorProtocol, networkPerformer: NetworkOperationPerformer, networkAvailableTimeout: TimeInterval = networkLabelTreshold, downloadTimeout: TimeInterval = networkOperationTimeout) {
        self.router = router
        self.urlSession = urlSession
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
    static let imageUrl: String = "https://lorempokemon.fakerapi.it/pokemon/300/89"
    
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
        Task { // Runnare in background
            let result = await networkPerformer.perform(withinSeconds: downloadTimeout) {
                do {
//                    try! await Task.sleep(nanoseconds: 2_000_000_000)
                    guard let url = URL(string: LoadingViewModel.imageUrl) else { return .failure(.genericError) }
                    let (data, response) = try await self.urlSession.data(from: url)
                    guard let response = response as? HTTPURLResponse,
                            (200...299).contains(response.statusCode) else {
                        throw URLError(.badServerResponse)
                    }
                    return .success(.imageDownload(data: data))
                } catch {
                    print("\(error)")
                    return .failure(.genericError)
                }
            }
            
            if case let .success(.imageDownload(data)) = result {
                router.navigate(to: .imageScreen(imageData: UIImage(data: data)))
                return
            }
            
            router.navigate(to: .imageScreen(imageData: nil))
        }
    }
}
