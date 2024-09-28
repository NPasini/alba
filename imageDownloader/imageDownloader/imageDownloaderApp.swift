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
    
    var body: some Scene {
        WindowGroup {
            NavigationStackView(
                model: LoadingViewModel(
                    httpClient: httpClient, 
                    networkMonitor: NWNetworkMonitor(),
                    networkPerformer: NetworkOperationPerformer(networkMonitor: NWNetworkMonitor()),
                    onDownloadCompleted: { data in
                        router.navigate(to: .imageScreen(imageData: data))
                    }
                ),
                router: router
            )
        }
    }
}
