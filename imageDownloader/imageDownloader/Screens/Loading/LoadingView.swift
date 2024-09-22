//
//  LoadingView.swift
//  imageDownloader
//
//  Created by nicolo.pasini on 22/09/24.
//

import SwiftUI

struct LoadingView: View {
//    private let model: LoadingViewModel
    
    var body: some View {
        ZStack {
            Color.loadingBackground
            SpinnerView(color: .gray)
        }
    }
    
//    init(model: LoadingViewModel) {
//        self.model = model
//    }
}

#Preview {
    LoadingView()
}
