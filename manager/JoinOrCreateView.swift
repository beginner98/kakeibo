import SwiftUI

struct JoinOrCreateView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                NavigationLink("作成されている家計簿に参加") {
                    JoinView()
                }
                NavigationLink("家計簿の作成") {
                    CreateView()
                }
            }
            .navigationTitle("家計簿に参加または作成")
        }
    }
}
