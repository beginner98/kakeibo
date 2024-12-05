import SwiftUI

struct HomeView: View {
    @State private var isShowingAddExpenseView = false
    @State private var balanceText: String = "計算中..."
    @State private var payfrom: String = "くわ"
    @State private var payto: String = "はな"
    
    @AppStorage("user1Name") private var user1Name: String = "Person 1"
    @AppStorage("user2Name") private var user2Name: String = "Person 2"
    @AppStorage("householdID") private var householdID: String = ""

    var body: some View {
        NavigationView {
            ZStack{
                Color.mint
                    .ignoresSafeArea()
                VStack(spacing: 20) {
                    ZStack{
                        Color.white
                        VStack{
                            HStack{
                                Text(payfrom)
                                    .font(.system(size: 35))
                                    .padding(10)
                                Image(systemName: "arrowshape.right.fill")
                                    .font(.system(size: 30))
                                Text(payto)
                                    .font(.system(size: 35))
                                    .padding(10)
                            }
                            .padding()
                            HStack{
                                Text(balanceText)
                                    .font(.system(size: 35))
                                    .font(.headline)
                                Button(action: {
                                    calculateBalances()
                                }) {
                                    Image(systemName: "arrow.trianglehead.counterclockwise.rotate.90")
                                        .font(.system(size: 15))
                                        .foregroundColor(.white)
                                        .padding(5)
                                        .background(Color.gray)
                                        .cornerRadius(100)
                                        .padding(7)
                                }

                            }
                            .padding()
                        }
                    }
                    .frame(width: 320, height:250)
                    .cornerRadius(10)
                    
                    Button("支出を追加/精算") {
                        isShowingAddExpenseView = true
                    }
                    .font(.system(size:25))
                    .frame(width: 320, height: 120)
                    .background(Color.pink)
                    .foregroundStyle(.white)

                    .cornerRadius(10)
                    .sheet(isPresented: $isShowingAddExpenseView) {
                        AddExpenseView()
                    }
                    HStack{
                        NavigationLink(destination: ListView()) {
                            Image(systemName: "book")
                                .font(.system(size:40))
                                .frame(width: 124, height: 80)
                                .buttonStyle(.borderedProminent)
                                .padding()
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                        }
                        
                        NavigationLink(destination: OptionView()) {
                            Image(systemName: "gearshape")
                                .font(.system(size:40))
                                .frame(width: 124, height: 80)
                                .buttonStyle(.borderedProminent)
                                .padding()
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .onAppear {
                    calculateBalances()
                }
            }
        }
        .background(Color.red)
    }

    /// 支払い金額の計算
    private func calculateBalances() {
        balanceText = "計算中..." // 更新前に一旦メッセージをリセット

        // householdIDが空でないか確認
        guard !householdID.isEmpty else {
            DispatchQueue.main.async {
                balanceText = "20000"
            }
            return
        }

        FirebaseManager.shared.getExpenses(forHouseholdID: householdID) { expenses in
            var user1Total = 0
            var user2Total = 0

            for expense in expenses {
                let amount = (expense.paymentType == "立て替え" || expense.paymentType == "精算") ? expense.amount * 2 : expense.amount
                
                if expense.person == user1Name {
                    user1Total += amount
                } else if expense.person == user2Name {
                    user2Total += amount
                }
            }

            DispatchQueue.main.async {
                if user1Total > user2Total {
                    payfrom = user2Name
                    payto = user1Name
                    balanceText = "\((user1Total - user2Total)/2)円"
                } else if user2Total > user1Total {
                    payfrom = user1Name
                    payto = user2Name
                    balanceText = "\((user2Total - user1Total)/2)円"
                } else {
                    balanceText = "Thank You!"
                }
            }
        }
    }
}
struct AddExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
