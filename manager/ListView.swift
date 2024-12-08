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
        ZStack {
            Color.offwhite
                .ignoresSafeArea()
            VStack{
                List(expenses, id: \.id) { expense in
                    VStack(alignment: .leading) {
                        HStack {
                            Text("\(expense.date, formatter: dateFormatter)")
                            Spacer()
                            Text("\(expense.person)")
                            Spacer()
                            Text("\(expense.amount)円")
                            Spacer()
                            Text("\(expense.paymentType)")
                        }
                        .padding(.bottom, 5)
                        .onTapGesture {
                            withAnimation {
                                if expandedExpenseID == expense.id {
                                    expandedExpenseID = nil
                                } else {
                                    expandedExpenseID = expense.id
                                }
                            }
                        }
                        
                        if expandedExpenseID == expense.id {
                            VStack(alignment: .leading) {
                                HStack{
                                    VStack(alignment: .leading){
                                        Text("カテゴリ: \(expense.category)")
                                        Text("メモ: \(expense.memo)")
                                    }
                                    .onTapGesture {
                                        withAnimation {
                                            if expandedExpenseID == expense.id {
                                                expandedExpenseID = nil
                                            } else {
                                                expandedExpenseID = expense.id
                                            }
                                        }
                                    }
                                    Spacer()
                                        .onTapGesture {
                                            withAnimation {
                                                if expandedExpenseID == expense.id {
                                                    expandedExpenseID = nil
                                                } else {
                                                    expandedExpenseID = expense.id
                                                }
                                            }
                                        }
                                    Button(action: {
                                        editingExpense = expense // 編集対象をセット
                                    }) {
                                        Image(systemName:"pencil")
                                            .font(.system(size: 30))
                                            .foregroundStyle(.yellow)
                                    }
                                }
                            }
                            .padding(.top, 5)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .onAppear {
                    loadExpenses()
                }
                
                // 編集用のビュー
                if let editingExpense = editingExpense {
                    EditExpenseView(expense: editingExpense, onSave: { updatedExpense in
                        updateExpense(updatedExpense)
                    }, onCancel: {
                        self.editingExpense = nil
                    })
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
                }
            }
        }
    }
    
    private func loadExpenses() {
        guard !savedHouseholdID.isEmpty else { return }
        
        FirebaseManager.shared.getExpenses(forHouseholdID: savedHouseholdID) { fetchedExpenses in
            let sortedExpenses = fetchedExpenses.sorted { $0.date > $1.date }
            expenses = sortedExpenses
        }
    }

    
    private func updateExpense(_ updatedExpense: Expense) {
        guard !savedHouseholdID.isEmpty else { return }
        
        FirebaseManager.shared.updateExpense(expenseID: updatedExpense.id, householdID: savedHouseholdID, updatedExpense: updatedExpense) { success in
            if success {
                if let index = expenses.firstIndex(where: { $0.id == updatedExpense.id }) {
                    expenses[index] = updatedExpense
                }
                self.editingExpense = nil
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}
