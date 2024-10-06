import Foundation
import PlaygroundSupport
import networkPerformer_Sources

PlaygroundPage.current.needsIndefiniteExecution = true

typealias SomeType = Bool

let networkOperationClosure: () async -> SomeType = {
    // Long-lasting network operation.
    return true
}

let result = await NetworkOperationPerformer().perform(withinSeconds: 3) {
    return await networkOperationClosure()
}

PlaygroundPage.current.finishExecution()
