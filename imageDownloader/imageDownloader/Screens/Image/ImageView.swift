//
//  ImageView.swift
//  imageDownloader
//
//  Created by nicolo.pasini on 22/09/24.
//

import SwiftUI

struct ImageView: View {
    private let image: UIImage?
    
    var body: some View {
        if let image {
            Image(uiImage: image)
        } else {
            Text("The pokemon did not show 😞")
        }
    }
    
    init(image: UIImage?) {
        self.image = image
    }
}

#Preview("ImageView") {
    Group {
        ImageView(image: UIImage(named: "bellsprout"))
        ImageView(image: nil)
    }
}
