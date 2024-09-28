//
//  NavigationStackView.swift
//  imageDownloader
//
//  Created by nicolo.pasini on 24/09/24.
//

import SwiftUI

struct NavigationStackView: View {
    private let model: LoadingViewModel
    
    @Bindable private var router: Router
    
    var body: some View {
        NavigationStack(path: $router.path) {
            LoadingView(model: model)
                .navigationTitle(Text.loadingScreenTitle)
            .navigationDestination(for: Router.Destination.self) { destination in
                switch destination {
                case let .imageScreen(imageData):
                    ImageView(model: ImageViewModel(imageData: imageData))
                        .navigationBarBackButtonHidden(true)
                        .navigationTitle(Text.imageScreenTitle)
                }
            }
        }
    }
    
    init(model: LoadingViewModel, router: Router) {
        self.model = model
        self.router = router
    }
}

private extension NavigationStackView {
    enum Text {
        static let imageScreenTitle = "Random Pokemon"
        static let loadingScreenTitle = "Loading data"
    }
}
