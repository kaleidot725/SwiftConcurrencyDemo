//: [Previous](@previous)

import _Concurrency
import Foundation

actor A {}
// actor B: A {} // Actor types do not support inheritance

actor C {
    var number: Int = 0
    func update(with value: Int) {
        number = value
    }
}

let c = C()
Task.detached {
    await c.update(with: 1)
    // await c.number = 1 // Actorのプロパティを外から直接更新
}

actor B: Hashable {
    static func == (lhs: B, rhs: B) -> Bool {
        lhs.id == rhs.id
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let id: UUID = .init()
    private(set) var number = 0
    func increace() {
        number += 1
    }
}

let b = B()
let dic = [b: "xxx"]

// actor D: Hashable {
//    private var number = 0 // error: actor-isolated property 'number' can not be referenced from a non-isolated context
//
//    static func == (lhs: D, rhs: D) -> Bool {
//        lhs.number == rhs.number
//    }
//
//    nonisolated func hash(into hasher: inout Hasher) {
//        hasher.combine(number)
//    }
// }

//: [Next](@next)
