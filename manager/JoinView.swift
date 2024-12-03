import SwiftUI

struct JoinView: View {
    @State private var householdID = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @AppStorage("isJoined") private var isJoined = false
    @AppStorage("householdID") private var savedHouseholdID = "" // 家計簿IDをAppStorageで保持
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("家計簿ID", text: $householdID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)  // 大文字小文字を区別
                .disableAutocorrection(true)
            
            SecureField("パスワード", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("参加する") {
                // 入力が空かどうかのチェック
                guard !householdID.isEmpty, !password.isEmpty else {
                    errorMessage = "IDまたはパスワードを入力してください"
                    return
                }
                
                // Firestoreで家計簿IDが存在し、パスワードが一致するか確認
                FirebaseManager.shared.joinHousehold(id: householdID, password: password) { isSuccess in
                    if isSuccess {
                        // ログイン成功
                        savedHouseholdID = householdID // 家計簿IDをAppStorageに保存
                        isJoined = true
                    } else {
                        // エラーメッセージ設定
                        errorMessage = "IDまたはパスワードが間違っています"
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            
            // エラーメッセージの表示
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("家計簿への参加")
    }
}
