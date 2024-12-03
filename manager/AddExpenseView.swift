import SwiftUI

struct AddExpenseView: View {
    @State private var date = Date()
    @State private var memo = ""
    @State private var amount = ""
    @State private var selectedCategory = "食費"
    @State private var selectedPerson = ""
    @State private var paymentType = "割り勘"
    @AppStorage("householdID") private var savedHouseholdID = ""
    
    let categories = ["食費", "交通費", "趣味", "その他"]
    let paymentTypes = ["割り勘", "立て替え"]
    let members = ["Person 1", "Person 2"]

    var body: some View {
        VStack(spacing: 20) {
            DatePicker("日付", selection: $date, displayedComponents: .date)
                .datePickerStyle(WheelDatePickerStyle())

            TextField("メモ", text: $memo)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("金額", text: $amount)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Picker("カテゴリ", selection: $selectedCategory) {
                ForEach(categories, id: \.self) { category in
                    Text(category)
                }
            }
            .pickerStyle(MenuPickerStyle())

            Picker("払った人", selection: $selectedPerson) {
                ForEach(members, id: \.self) { person in
                    Text(person)
                }
            }
            .pickerStyle(MenuPickerStyle())

            Picker("支払いの種類", selection: $paymentType) {
                ForEach(paymentTypes, id: \.self) { type in
                    Text(type)
                }
            }
            .pickerStyle(MenuPickerStyle())

            Button("保存") {
                saveExpenseData()
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
        .navigationTitle("出費の追加")
    }

    private func saveExpenseData() {
        guard let amount = Int(amount) else { return }
        FirebaseManager.shared.addExpense(
            householdID: savedHouseholdID,  // 家計簿IDを渡す
            date: date,
            memo: memo,
            amount: amount,
            category: selectedCategory,
            person: selectedPerson,
            paymentType: paymentType,
            imageData: nil // 画像データなし
        ) { success in
            if success {
                print("データ保存成功")
            } else {
                print("データ保存失敗")
            }
        }
        
    }
}
