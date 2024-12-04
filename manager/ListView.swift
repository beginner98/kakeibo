import SwiftUI
import FirebaseAuth

struct Expense: Identifiable {
    var id: String
    var date: Date
    var person: String
    var amount: Int
    var paymentType: String
    var category: String
    var memo: String
}

struct ListView: View {
    @AppStorage("householdID") private var savedHouseholdID: String = ""
    @State private var expenses: [Expense] = []
    @State private var expandedExpenseID: String? = nil
    @State private var editingExpense: Expense? = nil

    var body: some View {
        VStack {
            List(expenses, id: \.id) { expense in
                VStack(alignment: .leading) {
                    HStack {
                        Text("日付: \(expense.date, formatter: dateFormatter)")
                        Spacer()
                        Text("支出者: \(expense.person)")
                        Spacer()
                        Text("金額: ¥\(expense.amount)")
                        Spacer()
                        Text("支払い方法: \(expense.paymentType)")
                    }
                    .padding(.bottom, 5)
                    
                    if expandedExpenseID == expense.id {
                        VStack(alignment: .leading) {
                            Text("カテゴリ: \(expense.category)")
                            Text("メモ: \(expense.memo)")
                            
                            Button(action: {
                                editingExpense = expense // 編集対象をセット
                            }) {
                                Text("編集")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.top, 5)
                        .foregroundColor(.gray)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        if expandedExpenseID == expense.id {
                            expandedExpenseID = nil
                        } else {
                            expandedExpenseID = expense.id
                        }
                    }
                }
            }
            .onAppear {
                loadExpenses()
            }
            
            // 編集用のモーダルビューを表示
            if let editingExpense = editingExpense {
                EditExpenseView(expense: editingExpense, onSave: { updatedExpense in
                    updateExpense(updatedExpense)
                }, onCancel: {
                    self.editingExpense = nil
                })
                .transition(.move(edge: .bottom)) // 下から上に表示される
                .zIndex(1) // 編集画面を前面に表示
                .animation(.easeInOut) // アニメーション追加
            }
        }
    }
    
    private func loadExpenses() {
        guard !savedHouseholdID.isEmpty else { return }
        
        FirebaseManager.shared.getExpenses(forHouseholdID: savedHouseholdID) { fetchedExpenses in
            expenses = fetchedExpenses
        }
    }
    
    private func updateExpense(_ updatedExpense: Expense) {
        guard !savedHouseholdID.isEmpty else { return }
        
        FirebaseManager.shared.updateExpense(expenseID: updatedExpense.id, householdID: savedHouseholdID, updatedExpense: updatedExpense) { success in
            if success {
                if let index = expenses.firstIndex(where: { $0.id == updatedExpense.id }) {
                    expenses[index] = updatedExpense
                }
                self.editingExpense = nil // 編集を終了
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}
