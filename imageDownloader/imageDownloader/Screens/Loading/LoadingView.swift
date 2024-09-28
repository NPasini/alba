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
    LoadingView(
        model: LoadingViewModel(
            httpClient: HTTPClientMock(),
            networkMonitor: NetworkMonitorMock.available,
            networkPerformer: NetworkOperationPerformer(networkMonitor: NetworkMonitorMock.available),
            onDownloadCompleted: { _ in
                print("Download completed")
            }
        )
    )
}

#Preview("LoadingView - Not Available Network") {
    LoadingView(
        model: LoadingViewModel(
            httpClient: HTTPClientMock(),
            networkMonitor: NetworkMonitorMock.neverAvailable,
            networkPerformer: NetworkOperationPerformer(networkMonitor: NetworkMonitorMock.neverAvailable),
            onDownloadCompleted: { _ in
                print("Download completed")
            }
        )
    )
}
