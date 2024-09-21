import Foundation
import PlaygroundSupport
import networkPerformer_Sources

PlaygroundPage.current.needsIndefiniteExecution = true

let networkOperationClosure: AsyncOperation = {
    // Long-lasting network operation.
    return .success(.networkTask)
}

let performer = NetworkOperationPerformer()

let result = await performer.perform(withinSeconds: 3) {
    return await networkOperationClosure()
}

try! await Task.sleep(nanoseconds: 1_000_000_000)
//performer.cancelTask()

PlaygroundPage.current.finishExecution()
