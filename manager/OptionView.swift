import SwiftUI
import FirebaseAuth

struct OptionView: View {
    @AppStorage("householdID") private var savedHouseholdID: String = ""
    @AppStorage("user1Name") private var user1Name: String = "Person 1"
    @AppStorage("user2Name") private var user2Name: String = "Person 2"
    @State private var tempUser1Name: String = ""
    @State private var tempUser2Name: String = ""
    @State private var isExporting = false
    @State private var showLogoutConfirmation = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("設定画面")
                .font(.largeTitle)
                .padding()

            VStack(alignment: .leading, spacing: 15) {
                Text("名前の設定")
                    .font(.headline)
                
                HStack {
                    TextField("ユーザー①の名前", text: $tempUser1Name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onAppear {
                            tempUser1Name = user1Name
                        }
                    Button("変更") {
                        updateName(oldName: user1Name, newName: tempUser1Name) { success in
                            if success {
                                user1Name = tempUser1Name
                                alertMessage = "ユーザー①の名前を \(tempUser1Name) に変更しました"
                            } else {
                                alertMessage = "名前の変更に失敗しました"
                            }
                            showAlert = true
                        }
                    }
                    .buttonStyle(.bordered)
                }

                HStack {
                    TextField("ユーザー②の名前", text: $tempUser2Name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onAppear {
                            tempUser2Name = user2Name
                        }
                    Button("変更") {
                        updateName(oldName: user2Name, newName: tempUser2Name) { success in
                            if success {
                                user2Name = tempUser2Name
                                alertMessage = "ユーザー②の名前を \(tempUser2Name) に変更しました"
                            } else {
                                alertMessage = "名前の変更に失敗しました"
                            }
                            showAlert = true
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()

            Button("支出データをエクスポート") {
                exportDataAsCSV()
            }
            .buttonStyle(.borderedProminent)
            .padding()

            Button("ログアウト") {
                showLogoutConfirmation = true
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .alert(isPresented: $showLogoutConfirmation) {
                Alert(
                    title: Text("確認"),
                    message: Text("ログアウトしますか？"),
                    primaryButton: .destructive(Text("ログアウト")) {
                        logout()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("通知"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func exportDataAsCSV() {
        FirebaseManager.shared.getExpenses(forHouseholdID: savedHouseholdID) { expenses in
            guard !expenses.isEmpty else {
                print("エクスポートするデータがありません")
                return
            }

            let csvContent = generateCSVContent(from: expenses)
            saveCSVToFile(content: csvContent)
        }
    }

    private func updateName(oldName: String, newName: String, completion: @escaping (Bool) -> Void) {
        guard !newName.isEmpty, newName != oldName else {
            completion(false)
            return
        }

        let db = FirebaseManager.shared.db
        let expensesRef = db.collection("households").document(savedHouseholdID).collection("expenses")
        
        expensesRef.whereField("person", isEqualTo: oldName).getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("データ取得失敗: \(error?.localizedDescription ?? "不明なエラー")")
                completion(false)
                return
            }

            let batch = db.batch()
            for document in documents {
                batch.updateData(["person": newName], forDocument: document.reference)
            }
            
            batch.commit { error in
                if let error = error {
                    print("名前の一括更新に失敗: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("名前の一括更新に成功")
                    completion(true)
                }
            }
        }
    }

    private func generateCSVContent(from expenses: [Expense]) -> String {
        var csv = "日付,支出者,金額,支払い方法,カテゴリ,メモ\n"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short

        for expense in expenses {
            let dateStr = dateFormatter.string(from: expense.date)
            csv += "\(dateStr),\(expense.person),\(expense.amount),\(expense.paymentType),\(expense.category),\(expense.memo)\n"
        }
        return csv
    }

    private func saveCSVToFile(content: String) {
        let fileName = "expenses.csv"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try content.write(to: path, atomically: true, encoding: .utf8)
            print("CSVファイルを保存しました: \(path)")
            isExporting = true

            let activityVC = UIActivityViewController(activityItems: [path], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true, completion: nil)
            }
        } catch {
            print("CSVファイルの保存に失敗しました: \(error.localizedDescription)")
        }
    }

    private func logout() {
        do {
            try Auth.auth().signOut()
            print("ログアウト成功")
        } catch {
            print("ログアウト失敗: \(error.localizedDescription)")
        }
    }
}
