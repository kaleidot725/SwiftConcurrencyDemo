//: [Previous](@previous)

import _Concurrency
import PlaygroundSupport
import UIKit
PlaygroundPage.current.needsIndefiniteExecution = true

func request(url: URL, completionHandler: @escaping (Result<UIImage, Error>) -> ()) {
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
        guard error == nil else { return }
        downloadImage(data: data) { result in
            let image = try? result.get()
            resizeImage(image: image) { result in
                completionHandler(result)
            }
        }
    }
    task.resume()
}

func downloadImage(data: Data?,
                   completionHandler: @escaping (Result<UIImage, Error>) -> ()) {}

func resizeImage(image: UIImage?,
                 completionHandler: @escaping (Result<UIImage, Error>) -> ()) {}

let url = URL(string: "https://example.com")!
var isLoading = true
request(url: url) { result in
    isLoading = false
    switch result {
        case .success(let image):
            print(image)
        case .failure(let error):
            print(error.localizedDescription)
    }
}

//: [Next](@next)
