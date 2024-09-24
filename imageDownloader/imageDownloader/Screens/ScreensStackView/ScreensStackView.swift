//
//  ScreensStackView.swift
//  imageDownloader
//
//  Created by nicolo.pasini on 24/09/24.
//

import SwiftUI

struct ScreensStackView: View {
    private let model: LoadingViewModel
    
    @Bindable private var router: Router
    
    var body: some View {
        NavigationStack(path: $router.path) {
            LoadingView(model: model)
            .navigationDestination(for: Router.Destination.self) { destination in
                print("Test - Displaying \(destination)")
                switch destination {
                case let .imageScreen(imageData):
                    print("Test - Displaying image Screen")
                    return ImageView(model: ImageViewModel(imageData: imageData))
                }
            }
        }
    }
    
    init(model: LoadingViewModel, router: Router) {
        self.model = model
        self.router = router
    }
}
