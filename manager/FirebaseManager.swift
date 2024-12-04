import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private init() {}

    // 家計簿IDがユニークかを確認
    func isHouseholdIDUnique(_ id: String, completion: @escaping (Bool) -> Void) {
        db.collection("households").whereField("householdID", isEqualTo: id).getDocuments { (snapshot, error) in
            if let error = error {
                print("エラーが発生しました: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(snapshot?.documents.isEmpty ?? false) // ユニークであればtrue
            }
        }
    }

    // 家計簿を作成する
    func createHousehold(id: String, password: String, completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "ユーザーが未ログインです"]))
            return
        }
        let householdRef = db.collection("households").document(id)
        householdRef.setData([
            "householdID": id,
            "password": password,
            "members": [userID] // 家計簿作成者を初期メンバーに追加
        ]) { error in
            completion(error)
        }
    }

    // 家計簿に参加する
    func joinHousehold(id: String, password: String, completion: @escaping (Bool) -> Void) {
            db.collection("households").document(id).getDocument { snapshot, error in
                guard let data = snapshot?.data(),
                      let storedPasswordHash = data["passwordHash"] as? String else {
                    completion(false)
                    return
                }

                let inputPasswordHash = self.hashPassword(password)
                if storedPasswordHash == inputPasswordHash {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    
    private func hashPassword(_ password: String) -> String {
            let data = Data(password.utf8)
            let hash = data.map { String(format: "%02x", $0) }.joined()
            return hash
        }

    // 出費を追加する
    func addExpense(
        householdID: String,
        date: Date,
        memo: String,
        amount: Int,
        category: String,
        person: String,
        paymentType: String,
        imageData: Data?,
        completion: @escaping (Bool) -> Void
    ) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        let expenseData: [String: Any] = [
            "date": date,
            "memo": memo,
            "amount": amount,
            "category": category,
            "person": person,
            "paymentType": paymentType,
            "userID": userID,
            "imageData": imageData ?? Data() // 画像がない場合は空のData
        ]
        // "Household" コレクション内の家計簿IDのドキュメントに保存
        db.collection("households").document(householdID).collection("expenses").addDocument(data: expenseData) { error in
            if let error = error {
                print("データ保存失敗: \(error.localizedDescription)")
                completion(false)
            } else {
                print("データ保存成功")
                completion(true)
            }
        }
    }
    
    // 出費データを家計簿IDに基づいて取得
    func getExpenses(forHouseholdID householdID: String, completion: @escaping ([Expense]) -> Void) {
        db.collection("households")
            .document(householdID)
            .collection("expenses")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("データ取得失敗: \(error.localizedDescription)")
                    completion([])
                    return
                }

                var expenses: [Expense] = []
                for document in snapshot?.documents ?? [] {
                    let data = document.data()
                    
                    // date, person, amount, paymentType, category, memoの取得
                    if let date = (data["date"] as? Timestamp)?.dateValue(),
                       let person = data["person"] as? String,
                       let amount = data["amount"] as? Int,
                       let paymentType = data["paymentType"] as? String,
                       let category = data["category"] as? String, // 新しく追加された部分
                       let memo = data["memo"] as? String { // 新しく追加された部分
                        
                        // categoryとmemoを追加したExpenseを作成
                        let expense = Expense(
                            id: document.documentID,
                            date: date,
                            person: person,
                            amount: amount,
                            paymentType: paymentType,
                            category: category,  // 追加
                            memo: memo           // 追加
                        )
                        expenses.append(expense)
                    }
                }
                
                completion(expenses)
            }
    }

    func updateExpense(expenseID: String, householdID: String, updatedExpense: Expense, completion: @escaping (Bool) -> Void) {
            let expenseRef = db.collection("households")
                .document(householdID)
                .collection("expenses")
                .document(expenseID)
            
            let updatedData: [String: Any] = [
                "category": updatedExpense.category,
                "memo": updatedExpense.memo,
                "amount": updatedExpense.amount
            ]
            
            expenseRef.updateData(updatedData) { error in
                if let error = error {
                    print("データ更新失敗: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("データ更新成功")
                    completion(true)
                }
            }
        }

}
