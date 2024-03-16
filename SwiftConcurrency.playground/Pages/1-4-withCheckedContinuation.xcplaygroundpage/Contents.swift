//: [Previous](@previous)

import _Concurrency
import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

public enum APIClientError: Error {
    case invalidURL
    case responseError
    case parseError(Error)
    case serverError(Error)
    case badStatus(statusCode: Int)
    case noData
}

func request(with urlString: String, complecationHandler: @escaping (Result<String, APIClientError>) -> ()) {
    guard let url = URL(string: urlString) else {
        complecationHandler(.failure(.serverError(error)))
        return
    }

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            complecationHandler(.failure(.serverError(error)))
        } else {
            guard let httpStatus = response as? HTTPURLResponse else {
                complecationHandler(.failure(.responseError))
                return
            }
            switch httpStatus.statusCode {
                case 200 ..< 400:
                    guard let data = data else {
                        complecationHandler(.success(""))
                        return
                    }

                    guard let response = String(data: data, encoding: .utf8) else {
                        complecationHandler(.failure(.noData))
                        return
                    }
                    complecationHandler(.success(response))
                case 400...:
                    complecationHandler(.failure(.badStatus(statusCode: httpStatus.statusCode)))
                default:
                    fatalError()
            }
        }
    }
    task.resume()
}

func newAsyncRequest(with urlString: String) async throws -> String {
    return try await withCheckedContinuation { continuation in
        request(with: urlString) { result in
            continuation.resume(with: result)
        }
    }
}

@MainActor
class SomeViewModel {
    // nonisolatedでMainActorを無効にする
    noisolated func fetchUser() {}
}

class AnotherViewModel {
    @MainActor var url: URL?
    @MainActor func ditTapButton() {}
}

Task.detached {
    let urlString = "https://api.github.com/search/repositories?q=swift"
    let result = try await newAsyncRequest(with: urlString)
    print(result)
}

struct User {}
func fetchUser(userID: String, complecationHandler: @escapting((User?) -> ())) {
    if userID.isEmpty {
        complecationHandler(nil)
    } else {
        complecationHandler(User())
    }
}

func newAsyncFetchuser(userID: String) async -> User? {
    // withCheckedContinuationでawaitして、ブロックでresumeで戻り値を返すと、
    // awaitした箇所で戻り値を受け取ることができる仕組みになっているらしい
    return await withCheckedContinuation { continuation in
        fetchUser(userID: userID) { user in
            continuation.resume(returning: user)
        }
    }
}

Task.detached {
    let userID = "1234"
    let user = await newAsyncFetchuser(userID: userID)
    print(user ?? "")

    let noUser = await newAsyncFetchuser(userID: "")
    print(noUser ?? "no user")
}

//: [Next](@next)
