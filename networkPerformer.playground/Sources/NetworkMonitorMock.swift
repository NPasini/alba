import Foundation

public class NetworkMonitorMock: NetworkMonitorProtocol {
    public init() {}
    
    public func networkAvailabilityStream() -> AsyncStream<Bool> {
        AsyncStream<Bool> { continuation in
            Task {
                for await value in BoolGenerator() {
                    continuation.yield(value)
                }
                
                continuation.finish()
            }
        }
    }
    
    public func isInternetConnectionAvailable() -> Bool {
        false
    }
}

fileprivate struct BoolGenerator: AsyncSequence, AsyncIteratorProtocol {
    typealias Element = Bool
    private var counter = 0

    mutating func next() async -> Element? {
        try? await Task.sleep(nanoseconds: 500_000_000)
        counter += 1
        return counter == 30
    }

    func makeAsyncIterator() -> BoolGenerator {
        self
    }
}
