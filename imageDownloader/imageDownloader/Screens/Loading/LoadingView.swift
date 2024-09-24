//
//  LoadingView.swift
//  imageDownloader
//
//  Created by nicolo.pasini on 22/09/24.
//

import SwiftUI

struct LoadingView: View {
    private let model: LoadingViewModel
    @Bindable private var router: Router
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ZStack(alignment: .superViewCenterAlignment) {
                Color.loadingBackground
                VStack(spacing: 50) {
                    SpinnerView(color: .gray)
                        .alignmentGuide(.centerToSuperViewCenterAlignment) { $0.height / 2 }
                    if model.shouldDisplayNetworkNotAvailable {
                        Text("Network not available")
                    }
                }
            }
            .onAppear {
                print("OnAppear")
                model.onAppear()
            }
            .navigationDestination(for: Router.Destination.self) { destination in
                print("Destination \(destination)")
                switch destination {
                case let .imageScreen(image): return ImageView(image: image)
                }
            }
        }
    }
    
    init(model: LoadingViewModel, router: Router) {
        self.model = model
        self.router = router
    }
}

#Preview("LoadingView") {
    let router = Router()
    return LoadingView(
        model: LoadingViewModel(
            router: router,
            networkMonitor: NWNetworkMonitor(),
            networkPerformer: NetworkOperationPerformer()
        ), router: router
    )
}
