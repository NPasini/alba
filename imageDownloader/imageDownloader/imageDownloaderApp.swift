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
    
    var body: some Scene {
        WindowGroup {
            ScreensStackView(
                model: LoadingViewModel(
                    networkMonitor: NWNetworkMonitor(),
                    networkPerformer: NetworkOperationPerformer(), 
                    onDownloadCompleted: { data in
                        router.navigate(to: .imageScreen(imageData: data))
                    }
                ),
                router: router
            )
        }
    }
}
