//: [Previous](@previous)

import _Concurrency
import Foundation

class Score {
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

DispatchQueue.global(qos: .default).async {
    score.update(with: 100)
    print(score.highScore) // 110が出力される、これは他のスレッドから110をセットしているから
}

DispatchQueue.global(qos: .default).async {
    score.update(with: 110)
    print(score.highScore)
}

//: [Next](@next)
