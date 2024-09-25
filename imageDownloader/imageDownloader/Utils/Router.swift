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
    
    var path = [Router.Destination]()
    
    func navigate(to destination: Destination) {
        path.append(destination)
    }
}
