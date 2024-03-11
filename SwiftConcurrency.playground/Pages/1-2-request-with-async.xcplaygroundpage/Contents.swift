//: [Previous](@previous)

import _Concurrency
import PlaygroundSupport
import UIKit
PlaygroundPage.current.needsIndefiniteExecution = true

func request(url: URL) async throws -> UIImage {
    let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
    let image = try await downloadImage(data: data)
    let resizedImage = try await resizeImage(image: image)
    return resizedImage
}

func downloadImage(data: Data?) async throws -> UIImage {
    return UIImage()
}

func resizeImage(image: UIImage) async throws -> UIImage {
    return UIImage()
}

var isLoading = true
Task.detached {
    do {
        let url = URL(string: "https://api.github.com/search/repositories?q=swift")!
        let response = try await request(url: url)
        isLoading = false
        print(response)
    } catch {
        isLoading = false
        print(error.localizedDescription)
    }
}

//: [Next](@next)
