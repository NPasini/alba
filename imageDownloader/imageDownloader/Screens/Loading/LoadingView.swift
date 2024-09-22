//
//  LoadingView.swift
//  imageDownloader
//
//  Created by nicolo.pasini on 22/09/24.
//

import SwiftUI

struct LoadingView: View {
    @ObservedObject private var model: LoadingViewModel
    
    var body: some View {
        ZStack(alignment: .superViewCenterAlignment) {
            Color.loadingBackground
            VStack(spacing: 20) {
                SpinnerView(color: .gray)
                    .alignmentGuide(.centerToSuperViewCenterAlignment) { $0.height / 2 }
                Text("Network not available")
            }
        }
    }
    
    init(model: LoadingViewModel) {
        self.model = model
    }
}

#Preview {
    LoadingView(model: LoadingViewModel(
        networkMonitor: NWNetworkMonitor(),
        networkPerformer: NetworkOperationPerformer())
    )
}
