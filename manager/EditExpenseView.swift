import SwiftUI

struct EditExpenseView: View {
    var expense: Expense
    var onSave: (Expense) -> Void
    var onCancel: () -> Void
    
    @State private var updatedCategory: String
    @State private var updatedMemo: String
    @State private var updatedAmount: Int
    
    init(expense: Expense, onSave: @escaping (Expense) -> Void, onCancel: @escaping () -> Void) {
        self.expense = expense
        _updatedCategory = State(initialValue: expense.category)
        _updatedMemo = State(initialValue: expense.memo)
        _updatedAmount = State(initialValue: expense.amount)
        self.onSave = onSave
        self.onCancel = onCancel
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("カテゴリ:")
                TextField("カテゴリ", text: $updatedCategory)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Text("メモ:")
                TextField("メモ", text: $updatedMemo)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Text("金額:")
                TextField("金額", value: $updatedAmount, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                HStack {
                    Button("保存") {
                        let updatedExpense = Expense(
                            id: expense.id,
                            date: expense.date,
                            person: expense.person,
                            amount: updatedAmount,
                            paymentType: expense.paymentType,
                            category: updatedCategory,
                            memo: updatedMemo
                        )
                        onSave(updatedExpense)
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                    
                    Button("キャンセル") {
                        onCancel()
                    }
                    .padding()
                    .foregroundColor(.red)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 20)
            .padding()
        }
        .background(Color.black.opacity(0.3).edgesIgnoringSafeArea(.all))
    }
}
