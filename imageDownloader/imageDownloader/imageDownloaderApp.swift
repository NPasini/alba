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
    private let networkMonitor = NWNetworkMonitor()
    
    var body: some Scene {
        WindowGroup {
            ScreensStackView(
                model: LoadingViewModel(
                    httpClient: URLSessionHTTPClient(), 
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
