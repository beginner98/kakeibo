import SwiftUI

struct HomeView: View {
    // 追加画面を表示するための状態変数を宣言
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

                // 家計簿一覧表示ボタン
                NavigationLink(destination: ListView()) {
                    Text("家計簿一覧")
                        .buttonStyle(.borderedProminent)
                        .padding()
                }
            }
        }
    }
}
