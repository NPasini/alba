//import Foundation
//import PlaygroundSupport
//import networkPerformer_Sources
//
//PlaygroundPage.current.needsIndefiniteExecution = true
//
//typealias SomeType = Bool
//
//let networkOperationClosure: () async -> SomeType = {
//    // Long-lasting network operation.
//    return true
//}
//
//let result = await NetworkOperationPerformer().perform(withinSeconds: 3) {
//    return await networkOperationClosure()
//}
//
//PlaygroundPage.current.finishExecution()


import Foundation
import PlaygroundSupport
import networkPerformer_Sources

PlaygroundPage.current.needsIndefiniteExecution = true

let networkOperationClosure: () async -> Bool = {
    // Long-lasting network operation.
    return true
}

let counter = Counter()

//Task {
//    await NetworkOperationPerformer(networkMonitor: NetworkMonitorMock.neverAvailable).perform(withinSeconds: 3) {
//        await counter.increaseCounter()
//        let value = await counter.value
//        print("Running operation \(value)")
//        let x = await networkOperationClosure()
//        print("Completing operation \(value)")
//        return x
//    }
//}
//
//Task {
//    await NetworkOperationPerformer(networkMonitor: NetworkMonitorMock.available).perform(withinSeconds: 3) {
//        await counter.increaseCounter()
//        let value = await counter.value
//        print("Running operation \(value)")
//        let x = await networkOperationClosure()
//        print("Completing operation \(value)")
//        return x
//    }
//}

let t = Task {
    await NetworkOperationPerformer(networkMonitor: NetworkMonitorMock.initiallyNotAvailable).perform(withinSeconds: 3) {
        try! await Task.sleep(nanoseconds: 6_000_000_000)
        await counter.increaseCounter()
        let value = await counter.value
        print("Running operation \(value)")
        let x = await networkOperationClosure()
        print("Completing operation \(value)")
        return x
    }
}

//Task {
//    await NetworkOperationPerformer(networkMonitor: NetworkMonitorMock.available).perform(withinSeconds: 3) {
//        await counter.increaseCounter()
//        let value = await counter.value
//        print("Running operation \(value)")
//        let x = await networkOperationClosure()
//        print("Completing operation \(value)")
//        return x
//    }
//}

//Task {
//    await NetworkOperationPerformer(networkMonitor: NetworkMonitorMock.available).perform(withinSeconds: 3) {
//        await counter.increaseCounter()
//        let value = await counter.value
//        print("Running operation \(value)")
//        let x = await networkOperationClosure()
//        print("Completing operation \(value)")
//        return x
//    }
//}

Task {
    await NetworkOperationPerformer(networkMonitor: NetworkMonitorMock.initiallyNotAvailable).perform(withinSeconds: 5) {
        await counter.increaseCounter()
        let value = await counter.value
        print("Running operation \(value)")
        let x = await networkOperationClosure()
        print("Completing operation \(value)")
        return x
    }
}

try! await Task.sleep(nanoseconds: 1_000_000_000)
t.cancel()

//try! await Task.sleep(nanoseconds: 4_000_000_000)

await NetworkOperationPerformer(networkMonitor: NetworkMonitorMock.initiallyNotAvailable).perform(withinSeconds: 5) {
    await counter.increaseCounter()
    let value = await counter.value
    print("Running operation \(value)")
    let x = await networkOperationClosure()
    print("Completing operation \(value)")
    return x
}

actor Counter {
    var value = 0

    func increaseCounter() {
        value += 1
    }
}


PlaygroundPage.current.finishExecution()
