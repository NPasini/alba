//
//  API.swift
//  imageDownloader
//
//  Created by nicolo.pasini on 24/09/24.
//

import Foundation

enum ImageEndpoint: String {
    case getImage = "https://lorempokemon.fakerapi.it/pokemon/300/89"
    
    func url() -> URL? {
        URL(string: rawValue) ?? nil
    }
}
