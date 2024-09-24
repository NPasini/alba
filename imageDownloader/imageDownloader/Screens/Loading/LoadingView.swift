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
        .onAppear {
            print("Test - OnAppear")
            model.onAppear()
        }
    }
    
    init(model: LoadingViewModel) {
        self.model = model
    }
}

#Preview("LoadingView") {
    LoadingView(
        model: LoadingViewModel(
            networkMonitor: NWNetworkMonitor(),
            networkPerformer: NetworkOperationPerformer(), 
            onDownloadCompleted: { _ in
                print("Download completed")
            }
        )
    )
}
