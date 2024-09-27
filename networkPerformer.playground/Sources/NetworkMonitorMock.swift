import Foundation

public enum NetworkMonitorMock {
    public static let available: BaseNetworkMonitorMock = AvailableNetworkMonitorMock()
    public static let neverAvailable: BaseNetworkMonitorMock = NeverAvailableNetworkMonitorMock()
    public static let initiallyNotAvailable: BaseNetworkMonitorMock = InitiallyNotAvailableNetworkMonitorMock()
}

public class BaseNetworkMonitorMock: NetworkMonitorProtocol {
    private let networkInitiallyAvailable: Bool
    private let networkNotAvailableStreamLimit: Int
    private var continuation: AsyncStream<Bool>.Continuation?
    
    init(networkInitiallyAvailable: Bool, networkNotAvailableStreamLimit: Int = 0) {
        self.networkInitiallyAvailable = networkInitiallyAvailable
        self.networkNotAvailableStreamLimit = networkNotAvailableStreamLimit
    }
    
    deinit {
        continuation?.finish()
    }
    
    public func isInternetConnectionAvailable() -> Bool {
        networkInitiallyAvailable
    }
    
    public func networkAvailabilityStream() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            let task = Task {
                for await value in BoolGenerator(limit: networkNotAvailableStreamLimit) {
                    continuation.yield(value)
                }
                
                continuation.finish()
            }
                
            continuation.onTermination = { [task] _ in
                task.cancel()
            }
            
            self.continuation = continuation
        }
    }
}


fileprivate final class AvailableNetworkMonitorMock: BaseNetworkMonitorMock {
    init() {
        super.init(networkInitiallyAvailable: true)
    }
}

fileprivate class NeverAvailableNetworkMonitorMock: BaseNetworkMonitorMock {
    init() {
        super.init(networkInitiallyAvailable: false, networkNotAvailableStreamLimit: 30)
    }
}

fileprivate class InitiallyNotAvailableNetworkMonitorMock: BaseNetworkMonitorMock {
    init() {
        super.init(networkInitiallyAvailable: false, networkNotAvailableStreamLimit: 3)
    }
}

fileprivate struct BoolGenerator: AsyncSequence, AsyncIteratorProtocol {
    typealias Element = Bool

    private let limit: Int
    private var counter = 0

    init(limit: Int) {
        self.limit = limit
    }

    mutating func next() async -> Element? {
        try? await Task.sleep(nanoseconds: 500_000_000)
        counter += 1
        return counter == limit
    }

    func makeAsyncIterator() -> BoolGenerator {
        self
    }
}
