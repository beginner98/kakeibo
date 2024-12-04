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

                FirebaseManager.shared.joinHousehold(id: householdID, password: password) { isSuccess in
                    if isSuccess {
                        savedHouseholdID = householdID // 家計簿IDを保存
                        isJoined = true
                    } else {
                        errorMessage = "IDまたはパスワードが間違っています"
                    }
                }
            }
            .buttonStyle(.borderedProminent)

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
