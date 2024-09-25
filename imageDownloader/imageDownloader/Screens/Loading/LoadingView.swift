//
//  LoadingView.swift
//  imageDownloader
//
//  Created by nicolo.pasini on 22/09/24.
//

import SwiftUI

struct LoadingView: View {
    private let model: LoadingViewModel
    
    var body: some View {
        ZStack(alignment: .superViewCenterAlignment) {
            Color.loadingBackground
            VStack(spacing: 50) {
                SpinnerView(color: .gray)
                    .alignmentGuide(.centerToSuperViewCenterAlignment) { $0.height / 2 }
                if model.shouldDisplayNetworkNotAvailable {
                    Text(model.notAvailableNetworkText)
                }
            }
        }
        .task { await model.onAppear() }
    }
    
    init(model: LoadingViewModel) {
        self.model = model
    }
}

#Preview("LoadingView - Available Network") {
    let networkMonitor = NetworkMonitorMock.available
    return LoadingView(
        model: LoadingViewModel(
            httpClient: HTTPClientMock(),
            networkMonitor: networkMonitor,
            networkPerformer: NetworkOperationPerformer(networkMonitor: networkMonitor),
            onDownloadCompleted: { _ in
                print("Download completed")
            }
        )
    )
}

#Preview("LoadingView - Not Available Network") {
    let networkMonitor = NetworkMonitorMock.neverAvailable
    return LoadingView(
        model: LoadingViewModel(
            httpClient: HTTPClientMock(),
            networkMonitor: networkMonitor,
            networkPerformer: NetworkOperationPerformer(networkMonitor: networkMonitor),
            onDownloadCompleted: { _ in
                print("Download completed")
            }
        )
    )
}
