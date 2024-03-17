//: [Previous](@previous)

import _Concurrency
import Foundation

actor Score {
    var logs: [Int] = []
    private(set) var highScore: Int = 0

    func update(with score: Int) {
        logs.append(score)
        if score > highScore {
            highScore = score
        }
    }
}

let score = Score()

Task.detached {
    await score.update(with: 100) // awaitが必要になっている、他の処理が動作しているときは、待ちが生じるということだと思う
    print(await score.highScore)
}

Task.detached {
    await score.update(with: 110)
    print(await score.highScore)
}

//: [Next](@next)
