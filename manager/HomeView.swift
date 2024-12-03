import SwiftUI

struct HomeView: View {
    @State private var isShowingAddExpenseView = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("ホーム画面")
                    .font(.largeTitle)
                    .padding()
                
                Button("追加") {
                    // 追加画面に遷移
                    isShowingAddExpenseView = true
                }
                .buttonStyle(.borderedProminent)
                .padding()
                .sheet(isPresented: $isShowingAddExpenseView) {
                    // 追加画面のシート表示
                    AddExpenseView()
                }
            }
        }
    }
}
