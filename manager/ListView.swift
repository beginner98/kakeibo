import SwiftUI
import FirebaseAuth


struct Expense: Identifiable {
    var id: String
    var date: Date
    var person: String
    var amount: Int
    var paymentType: String
}

struct ListView: View {
    @AppStorage("householdID") private var savedHouseholdID = "" // 家計簿IDをAppStorageで保持
    @State private var expenses: [Expense] = []
    
    var body: some View {
        List(expenses, id: \.id) { expense in
            VStack(alignment: .leading) {
                Text("日付: \(expense.date, formatter: dateFormatter)")
                Text("支出者: \(expense.person)")
                Text("金額: ¥\(expense.amount)")
                Text("支払い方法: \(expense.paymentType)")
            }
        }
        .onAppear {
            loadExpenses()
        }
    }
    
    private func loadExpenses() {
        // savedHouseholdIDが空でない場合にデータを取得
        guard !savedHouseholdID.isEmpty else { return }
        
        FirebaseManager.shared.getExpenses(forHouseholdID: savedHouseholdID) { fetchedExpenses in
            expenses = fetchedExpenses
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}
