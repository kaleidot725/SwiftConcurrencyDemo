//: [Previous](@previous)

import _Concurrency
import PlaygroundSupport
import SwiftUI

@MainActor
class UserDataSource {
    var user: String = ""
    func updateUser() {}
    nonisolated func sendLogs() {}
}

struct Mypage {
    @MainActor
    var info: String = ""

    @MainActor
    func updateInfo() {}

    func sendLogs() {}
}

struct ContentView: View {
    @StateObject
    private var viewModel: ViewModel

    init() {
        _viewModel = StateObject(wrappedValue: ViewModel())
    }

    var body: some View {
        List {
            Text(viewModel.text)
            Button {
                viewModel.didTapButton()
            } label: {
                Text("text更新")
            }
        }
    }
}

@MainActor
final class ViewModel: ObservableObject {
    @Published
    private(set) var text: String = ""

    //    nonisolated func fetchUser() async {
    //        text = await waitOneSecond(with: "Arex")
    //    }

    nonisolated func fetchUser() async -> String {
        return await waitOneSecond(with: "Arex")
    }

    func didTapButton() {
        Task {
            text = ""
            text = await fetchUser()
        }
    }

    private func waitOneSecond(with string: String) async -> String {
        try? await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
        return string
    }
}

PlaygroundPage.current.setLiveView(ContentView())

//: [Next](@next)
