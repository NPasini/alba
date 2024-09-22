import Foundation
import PlaygroundSupport
import networkPerformer_Sources

PlaygroundPage.current.needsIndefiniteExecution = true

let networkOperationClosure: AsyncOperation = {
    // Long-lasting network operation.
    return .success(.networkTask)
}

let result = await NetworkOperationPerformer().perform(withinSeconds: 3) {
    return await networkOperationClosure()
}

PlaygroundPage.current.finishExecution()
