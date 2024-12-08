import SwiftUI
import FirebaseAuth

struct JoinView: View {
    @State private var householdID = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @AppStorage("isJoined") private var isJoined = false
    @AppStorage("householdID") private var savedHouseholdID = "" // 家計簿IDをAppStorageで保持

    var body: some View {
        ZStack{
            Color.gray
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Spacer()
                Text("家計簿に参加")
                    .font(.title)
                TextField("家計簿IDを入力", text: $householdID)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                SecureField("パスワード", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("参加する") {
                    // 入力が空かどうかのチェック
                    guard !householdID.isEmpty, !password.isEmpty else {
                        errorMessage = "IDまたはパスワードを入力してください"
                        return
                    }

                    // Firebase認証を実施
                    Auth.auth().signIn(withEmail: "\(householdID)@shared-household.com", password: hashPassword(password)) { result, error in
                        if let error = error {
                            // エラーが発生した場合、エラーメッセージを表示
                            errorMessage = "ログイン失敗: \(error.localizedDescription)"
                            return
                        }

                        // ログイン成功後、joinHouseholdで追加のチェック
                        FirebaseManager.shared.joinHousehold(id: householdID, password: password) { isSuccess in
                            if isSuccess {
                                savedHouseholdID = householdID // 家計簿IDを保存
                                isJoined = true
                            } else {
                                errorMessage = "IDまたはパスワードが間違っています"
                            }
                        }
                    }
                }
                .padding()
                .foregroundStyle(Color.black)
                .background(Color.yellow)
                .cornerRadius(10)
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
    private func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hash = data.map { String(format: "%02x", $0) }.joined()
        return hash
    }
}

struct JoinView_Previews: PreviewProvider {
    static var previews: some View {
        JoinView()
    }
}

