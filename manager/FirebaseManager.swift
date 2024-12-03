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
        let db = Firestore.firestore()
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
        let db = Firestore.firestore()
        let householdRef = db.collection("households").document(id)
        
        householdRef.setData([
            "householdID": id,
            "password": password
        ]) { error in
            completion(error)
        }
    }
    
    func joinHousehold(id: String, password: String, completion: @escaping (Bool) -> Void) {
        db.collection("households").document(id).getDocument { snapshot, error in
            guard let data = snapshot?.data(), let storedPassword = data["password"] as? String else {
                completion(false)
                return
            }
            completion(storedPassword == password)
        }
    }
    
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
            let expenseData: [String: Any] = [
                "date": date,
                "memo": memo,
                "amount": amount,
                "category": category,
                "person": person,
                "paymentType": paymentType,
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
    
}
