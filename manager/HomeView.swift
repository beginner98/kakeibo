import SwiftUI

struct HomeView: View {
    @State private var isShowingAddExpenseView = false
    @State private var balanceText: String = "計算中..."
    
    @AppStorage("user1Name") private var user1Name: String = "Person 1"
    @AppStorage("user2Name") private var user2Name: String = "Person 2"
    @AppStorage("householdID") private var householdID: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("ホーム画面")
                    .font(.largeTitle)
                    .padding()
                
                Text(balanceText)
                    .font(.headline)
                    .padding()
                
                // 更新ボタン
                Button("更新") {
                    calculateBalances()
                }
                .buttonStyle(.bordered)
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
            .onAppear {
                calculateBalances()
            }
        }
    }

    /// 支払い金額の計算
    private func calculateBalances() {
        print("計算結果を行います。")
        balanceText = "計算中..." // 更新前に一旦メッセージをリセット

        // householdIDが空でないか確認
        guard !householdID.isEmpty else {
            DispatchQueue.main.async {
                balanceText = "家計簿IDが設定されていません。"
            }
            return
        }

        FirebaseManager.shared.getExpenses(forHouseholdID: householdID) { expenses in
            var user1Total = 0
            var user2Total = 0

            for expense in expenses {
                let amount = expense.paymentType == "立て替え" ? expense.amount * 2 : expense.amount
                
                if expense.person == user1Name {
                    user1Total += amount
                } else if expense.person == user2Name {
                    user2Total += amount
                }
                print(expense.person)
                print(amount)
            }

            DispatchQueue.main.async {
                if user1Total > user2Total {
                    balanceText = "\(user2Name)から\(user1Name)に\(user1Total - user2Total)円"
                } else if user2Total > user1Total {
                    balanceText = "\(user1Name)から\(user2Name)に\(user2Total - user1Total)円"
                } else {
                    balanceText = "二人の支払い額は同じです"
                }
            }
        }
    }
}
