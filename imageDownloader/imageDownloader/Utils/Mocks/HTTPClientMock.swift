//
//  HTTPClientMock.swift
//  imageDownloader
//
//  Created by nicolo.pasini on 24/09/24.
//

import Foundation

class HTTPClientMock: HTTPClientProtocol {
    func getData(from url: URL) async throws -> Data {
        Data()
    }
}
