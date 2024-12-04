import SwiftUI
import FirebaseAuth

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
    
    // Environment変数を使ってビューを閉じる
    @Environment(\.dismiss) private var dismiss

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
        // FirebaseAuth で現在のユーザーを確認
        guard let user = Auth.auth().currentUser else {
            print("ログインしていないため、データを保存できません")
            return
        }
        
        guard let amount = Int(amount) else {
            print("金額の形式が正しくありません")
            return
        }
        
        // デバッグ用: ユーザー情報を確認
        print("保存を実行するユーザー: \(user.uid)")

        FirebaseManager.shared.addExpense(
            householdID: savedHouseholdID,  // 共有の家計簿IDをそのまま使用
            date: date,
            memo: memo,
            amount: amount,
            category: selectedCategory,
            person: selectedPerson,
            paymentType: paymentType,
            imageData: nil // 画像データは渡さない場合
        ) { success in
            if success {
                print("データ保存成功")
                dismiss()  // 保存後にHomeViewに戻る
            } else {
                print("データ保存失敗")
            }
        }
    }
}
