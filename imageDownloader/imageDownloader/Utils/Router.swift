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
        case imageScreen(imageData: UIImage?)
    }
    
    var path = NavigationPath()
    
    func navigate(to destination: Destination) {
        print("Path \(path)")
        path.append(destination)
    }
}
