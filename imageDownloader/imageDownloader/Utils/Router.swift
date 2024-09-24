//
//  Router.swift
//  imageDownloader
//
//  Created by nicolo.pasini on 22/09/24.
//

import SwiftUI

@Observable
final class Router {
    enum Destination: Hashable {
        case imageScreen(imageData: Data?)
    }
    
    var path = NavigationPath() {
        didSet {
            let x = 1
            print("Test - set new path \(path)")
        }
    }
    
    func navigate(to destination: Destination) {
        print("Test - Navigating to path \(path)")
        path.append(destination)
    }
}
