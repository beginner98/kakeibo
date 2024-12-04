import SwiftUI

struct HomeView: View {
    @State private var isShowingAddExpenseView = false
    @State private var isShowingListView = false // リスト表示用の状態変数

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
                Button("家計簿一覧") {
                    isShowingListView = true
                }
                .buttonStyle(.borderedProminent)
                .padding()
                .sheet(isPresented: $isShowingListView) {
                    // 家計簿一覧表示のシート表示
                    ListView()
                }
            }
        }
    }
}
