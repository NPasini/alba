//
//  imageDownloaderTests.swift
//  imageDownloaderTests
//
//  Created by nicolo.pasini on 22/09/24.
//

@testable import imageDownloader
import XCTest

final class imageDownloaderTests: XCTestCase {
    func testExample() async {
        var called = false
        let router = Router()
        let httpClinet = URLSessionHTTPClient()
        let networkMonitor1 = NWNetworkMonitor()
        let networkMonitor2 = NWNetworkMonitor()
        let performer = NetworkOperationPerformer(networkMonitor: networkMonitor1)
        let exp = expectation(description: "assd")
        exp.expectedFulfillmentCount = 3
        let sut = LoadingViewModel(httpClient: httpClinet, networkMonitor: networkMonitor2, networkPerformer: performer, networkAvailableTimeout: 0, downloadTimeout: 0) { _ in
            called = true
            exp.fulfill()
        }
        
        print("Test - onAppear started")
        let task = Task {
            await sut.onAppear()
            print("Test - onAppear completed")
        }
        let task1 = Task {
            await sut.onAppear()
            print("Test - onAppear completed")
        }
        let task2 = Task {
            await sut.onAppear()
            print("Test - onAppear completed")
        }
        await Task.yield()
        await task.value
        await task1.value
        await task2.value
        
        await fulfillment(of: [exp], timeout: 1)
        
        XCTAssertTrue(called)
        
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(router)
        trackForMemoryLeaks(httpClinet)
        trackForMemoryLeaks(performer)
        trackForMemoryLeaks(networkMonitor1)
        trackForMemoryLeaks(networkMonitor2)
    }
    
    func test1() {
        class A {
            var closure: Data? = nil
            var timer: Timer? = nil
            
            func start() {
                let xtimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
                    self?.closure = nil
                    self?.timer = nil
                    
                    NotificationCenter.default.removeObserver(self)
                }
            }
        }

        let a = A()
        a.start()

        trackForMemoryLeaks(a)
    }
}

public extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated, potential memory leak", file: file, line: line)
        }
    }
}
