//
// UserAPIsView.swift

import SwiftUI

struct UserAPIsView: View {
    @StateObject
    private var viewModel: UserAPIsViewModel

    init() {
        self._viewModel = StateObject(wrappedValue: UserAPIsViewModel())
    }
    
    var body: some View {
        VStack {
            TextEditor(text: $viewModel.text)
                .frame(height: 300)
            
            Button {
                viewModel.readText()
            } label: {
                Text("ファイル読み込み")
            }
        }
        .navigationTitle("APIを使う")
        .onAppear {
            viewModel.checkAppStatus()
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }
}

@MainActor
final class UserAPIsViewModel: ObservableObject {
    @Published
    var text: String = ""
    
    var enterForegroundTask: Task<Void, Never>?
    var enterBackgroundTask: Task<Void, Never>?
    
    func checkAppStatus() {
        let notificationCenter = NotificationCenter.default
        enterForegroundTask = Task {
            // Foregroundになったときの通知を受け取る、ObserveするのはTask内部でやるので、Taskを作成して終わったら破棄する
            // 今まではaddObserverを利用していたが、このようにfor await inで書くとaddObserverが必要なくなるので、Taskのキャンセルで対応する
            let willEnterForeground = notificationCenter.notifications(named: UIApplication.willEnterForegroundNotification)
            for await notification in willEnterForeground {
                // FOREGROUND name = UIApplicationWillEnterForegroundNotification, object = Optional(<_TtC7SwiftUIP33_ACC2C5639A7D76F611E170E831FCA49118SwiftUIApplication: 0x103f065c0>), userInfo = nil
                print("FOREGROUND \(notification)")
            }
        }
        
        enterBackgroundTask = Task {
            // Backgroundになったときの通知を受け取る、ObserveするのはTask内部でやるので、Taskを作成して終わったら破棄する
            // 今まではaddObserverを利用していたが、このようにfor await inで書くとaddObserverが必要なくなるので、Taskのキャンセルで対応する
            let didEnterBackground = notificationCenter.notifications(named: UIApplication.didEnterBackgroundNotification)
            for await notification in didEnterBackground {
                // BACKGROUND name = UIApplicationDidEnterBackgroundNotification, object = Optional(<_TtC7SwiftUIP33_ACC2C5639A7D76F611E170E831FCA49118SwiftUIApplication: 0x103f065c0>), userInfo = nil
                print("BACKGROUND \(notification)")
            }
        }
    }
    
    func readText() {
        Task {
            text = ""
            guard let url = Bundle.main.url(forResource: "text", withExtension: "txt") else { return }
            do {
                for try await line in url.lines {
                    print(line)
                    if line == "apple" {
                        continue
                    }
                    
                    if line == "five" {
                        break
                    }
                    
                    text += "\(line)\n"
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func cleanup() {
        enterForegroundTask?.cancel()
        enterBackgroundTask?.cancel()
    }
}

struct UserAPIsView_Previews: PreviewProvider {
    static var previews: some View {
        UserAPIsView()
    }
}
