//
//  HTTPClient.swift
//  imageDownloader
//
//  Created by nicolo.pasini on 24/09/24.
//

import Foundation

protocol HTTPClientProtocol {
    func getData(from url: URL) async throws -> Data
}

class URLSessionHTTPClient: HTTPClientProtocol {
    private let urlSession: URLSession
    
    init() {
        urlSession = .shared
    }
    
    func getData(from url: URL) async throws -> Data {
        let (data, response) = try await urlSession.data(from: url)
        guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return data
    }
}
