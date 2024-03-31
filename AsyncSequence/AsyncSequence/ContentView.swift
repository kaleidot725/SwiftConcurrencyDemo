//
// ContentView.swift

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("APIを使う") {
                    UserAPIsView()
                }
                NavigationLink("自分で作る") {
                    CustomAsyncSequence()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
