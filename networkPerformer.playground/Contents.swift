import Foundation
import PlaygroundSupport
import networkPerformer_Sources

PlaygroundPage.current.needsIndefiniteExecution = true

let networkOperationClosure: AsyncOperation = {
    // Long-lasting network operation.
    print("Test - Running operation 1")
    return .success(())
}

let result = await NetworkOperationPerformer().perform(withinSeconds: 3) {
    return await networkOperationClosure()
}

PlaygroundPage.current.finishExecution()
