//
//  ImageView.swift
//  imageDownloader
//
//  Created by nicolo.pasini on 22/09/24.
//

import SwiftUI

struct ImageView: View {
    private let model: ImageViewModel
    
    var body: some View {
        if let data = model.imageData, let image = UIImage(data: data) {
            Image(uiImage: image)
        } else {
            Text(model.failureText)
        }
    }
    
    init(model: ImageViewModel) {
        self.model = model
    }
}

#Preview("ImageView") {
    Group {
        let imgage = UIImage(named: "bellsprout")!
        let data = imgage.jpegData(compressionQuality: 1)
        ImageView(model: ImageViewModel(imageData: data))
        ImageView(model: ImageViewModel(imageData: nil))
    }
}
