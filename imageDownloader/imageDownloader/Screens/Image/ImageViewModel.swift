//
//  ImageViewModel.swift
//  imageDownloader
//
//  Created by nicolo.pasini on 24/09/24.
//

import UIKit

struct ImageViewModel {
    let imageData: Data?
    let failureText = "The pokemon did not show 😞"
    
    init(imageData: Data?) {
        self.imageData = imageData
    }
}
