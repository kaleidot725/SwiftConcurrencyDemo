//: [Previous](@previous)

import _Concurrency
import UIKit

actor Score {
    var localLogs: [Int] = []
    private(set) var highScore: Int = 0

    func update(with score: Int) async {
        highScore = await requestHighScore(with: score)
        localLogs.append(score)
    }

    func requestHighScore(with score: Int) async -> Int {
        try? await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)
        return score
    }
}

let score = Score()

Task.detached {
    await score.update(with: 100)
    print(await score.localLogs)
    print(await score.highScore)
}

Task.detached {
    await score.update(with: 110)
    print(await score.localLogs)
    print(await score.highScore)
}

actor ImageDownloader {
    private var cached: [String: UIImage] = [:]

    func image(from url: String) async -> UIImage {
        if cached.keys.contains(url) {
            return cached[url]!
        }

        let image = await downloadImage(from: url)
        if !cached.keys.contains(url) {
            cached[url] = image
        }
        return cached[url]!
    }

    func downloadImage(from url: String) async -> UIImage {
        try? await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)
        switch url {
        case "monster":
            let imageName = Bool.random() ? "cow" : "fox"
            return UIImage(named: imageName)!
        default:
            return UIImage()
        }
    }
}

let imageDownloader = ImageDownloader()
Task.detached {
    let image = await imageDownloader.image(from: "monster")
    print(image)

    // let image2 = await imageDownloader.image(from: "monster")
    // print(image2)
}

Task.detached {
    let image = await imageDownloader.image(from: "monster")
    print(image)
}

actor ImageDownloader2 {
    private enum CacheEntry {
        case inProgress(Task<UIImage, Never>)
        case ready(UIImage)
    }

    private var cache: [String: CacheEntry] = [:]

    func image(from url: String) async -> UIImage? {
        if let cached = cache[url] {
            switch cached {
            case .ready(let image):
                return image
            case .inProgress(let task):
                return await task.value
            }
        }

        let task = Task {
            await downloadImage(from: url)
        }

        cache[url] = .inProgress(task)
        let image = await task.value
        cache[url] = .ready(image)
        return image
    }

    func downloadImage(from url: String) async -> UIImage {
        print(NSEC_PER_SEC)
        try? await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)
        switch url {
        case "monster":
            let imageName = Bool.random() ? "cow" : "fox"
            return UIImage(named: imageName)!
        default:
            return UIImage()
        }
    }
}

let imageDownloader2 = ImageDownloader2()
Task.detached {
    let image = await imageDownloader2.image(from: "monster")
    print("image2: \(image.debugDescription)")
}

Task.detached {
    let image = await imageDownloader2.image(from: "monster")
    print("image2: \(image.debugDescription)")
}

//: [Next](@next)
