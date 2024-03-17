//: [Previous](@previous)

import Foundation

class Score {
    private let serialQueue = DispatchQueue(label: "serial-dispatch-queue")
    var logs: [Int] = []
    private(set) var highScore: Int = 0

    func update(with score: Int, completion: @escaping ((Int) -> ())) {
        serialQueue.async { [weak self] in
            guard let self = self else { return }
            self.logs.append(score)
            if score > self.highScore {
                self.highScore = score
            }
            completion(self.highScore)
        }
    }
}

let score = Score()
DispatchQueue.global(qos: .default).async {
    score.update(with: 100) { highScore in
        print(highScore)
    }
}

DispatchQueue.global(qos: .default).async {
    score.update(with: 110) { highScore in
        print(highScore)
    }
}

//: [Next](@next)
