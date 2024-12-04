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
                    isShowingAddExpenseView = true
                }
                .buttonStyle(.borderedProminent)
                .padding()
                .sheet(isPresented: $isShowingAddExpenseView) {
                    AddExpenseView()
                }

                NavigationLink(destination: ListView()) {
                    Text("家計簿一覧")
                        .buttonStyle(.borderedProminent)
                        .padding()
                }
                
                NavigationLink(destination: OptionView()) {
                    Text("設定")
                        .buttonStyle(.borderedProminent)
                        .padding()
                }
            }
        }
    }
}
