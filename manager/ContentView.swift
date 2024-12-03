import SwiftUI

struct ContentView: View {
    @AppStorage("isJoined") private var isJoined = false
    
    var body: some View {
        if isJoined {
            HomeView()
        } else {
            JoinOrCreateView()
        }
    }
}
