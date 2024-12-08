import SwiftUI
import Firebase

struct CreateView: View {
    @State private var householdID = UUID().uuidString.prefix(16).lowercased() // 家計簿ID
    @State private var password = "" // パスワード
    @State private var errorMessage = "" // エラーメッセージ
    @State private var isLoading = false // ローディング状態
    @AppStorage("isJoined") private var isJoined = false
    @AppStorage("householdID") private var savedHouseholdID = "" // 家計簿IDをAppStorageで保持

    var body: some View {
        ZStack{
            Color.gray
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Spacer()
                Text("家計簿を作成する")
                    .font(.largeTitle)
                // 家計簿IDの表示
                Text("新規家計簿ID: \(householdID)")
                    .font(.headline)
                    .padding(.top)
                
                // パスワード入力
                SecureField("パスワードを設定（8文字以上）", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // 作成ボタン
                Button("作成する") {
                    guard password.count >= 8 else {
                        errorMessage = "パスワードは8文字以上にしてください"
                        return
                    }
                    
                    isLoading = true
                    errorMessage = ""
                    
                    createHousehold()
                }
                .disabled(password.count < 8 || isLoading)
                .padding()
                .foregroundStyle(Color.black)
                .background(Color.yellow)
                .cornerRadius(10)
                
                // ローディング表示
                if isLoading {
                    ProgressView()
                }
                
                // エラーメッセージの表示
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("家計簿の作成")
        }
    }
    
    /// 家計簿を作成する処理
    private func createHousehold() {
        // Firebase Authenticationでカスタム認証を使用
        let email = "\(householdID)@shared-household.com" // 家計簿IDをメールアドレスの形式に変換
        let hashedPassword = hashPassword(password) // パスワードをハッシュ化

        // Firebase Authenticationに登録
        Auth.auth().createUser(withEmail: email, password: hashedPassword) { authResult, error in
            if let error = error {
                errorMessage = "家計簿の作成に失敗しました: \(error.localizedDescription)"
                isLoading = false
                return
            }

            // Firestoreに家計簿データを保存
            let householdData: [String: Any] = [
                "householdID": String(householdID),
                "passwordHash": hashedPassword,
                "createdAt": Timestamp()
            ]
            Firestore.firestore().collection("households").document(String(householdID)).setData(householdData) { firestoreError in
                if let firestoreError = firestoreError {
                    errorMessage = "Firestoreへの保存に失敗しました: \(firestoreError.localizedDescription)"
                } else {
                    print("家計簿が正常に作成されました")
                    savedHouseholdID = String(householdID) // 家計簿IDを保存
                    isJoined = true // 参加済み状態にする
                }
                isLoading = false
            }
        }
    }
    
    /// パスワードをハッシュ化する関数
    private func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hash = data.map { String(format: "%02x", $0) }.joined()
        return hash
    }
    
}

struct Create_Previews: PreviewProvider {
    static var previews: some View {
        CreateView()
    }
}
