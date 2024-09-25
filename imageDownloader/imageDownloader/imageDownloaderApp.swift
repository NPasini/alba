//
//  imageDownloaderApp.swift
//  imageDownloader
//
//  Created by nicolo.pasini on 22/09/24.
//

import SwiftUI

@main
struct imageDownloaderApp: App {
    private let router = Router()
    private let httpClient = URLSessionHTTPClient()
    private let networkMonitor = NWNetworkMonitor()
    
    var body: some Scene {
        WindowGroup {
            ScreensStackView(
                model: LoadingViewModel(
                    httpClient: httpClient, 
                    networkMonitor: networkMonitor,
                    networkPerformer: NetworkOperationPerformer(networkMonitor: networkMonitor),
                    onDownloadCompleted: { data in
                        router.navigate(to: .imageScreen(imageData: data))
                    }
                ),
                router: router
            )
        }
    }
}
