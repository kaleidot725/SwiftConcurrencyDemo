//: [Previous](@previous)

import _Concurrency
import Foundation

func a() async {
    print(#function)
}

Task.detached {
    await a()
}

func b() async -> String {
    return "result"
}

Task.detached {
    let result = await b()
    print(result)
}

struct AsyncError: Error {
    let message: String
}

func c(showError: Bool) async throws {
    if showError {
        throw AsyncError(message: "error")
    } else {
        print("no error")
    }
}

Task.detached {
    do {
        try await c(showError: true)
    } catch {
        print(error.localizedDescription)
    }
}

class D {
    init(label: String) async {
        print("イニシャライザーでasync")
    }
}

Task.detached {
    _ = await D(label: "")
}

Task.detached {
    print("### B AND D 1")
    let result = await b()
    let d = await D(label: result)
    print(d)
}

Task.detached {
    print("### B AND D 1")
    let d = await D(label: b())
    print(d)
}

//: [Next](@next)
