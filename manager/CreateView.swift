import SwiftUI
import Firebase

struct CreateView: View {
    @State private var householdID = UUID().uuidString.prefix(16).lowercased() // 家計簿ID
    @State private var password = "" // パスワード
    @State private var errorMessage = "" // エラーメッセージ
    @AppStorage("isJoined") private var isJoined = false // 参加状態を保持

    var body: some View {
        VStack(spacing: 20) {
            // 家計簿IDの表示
            Text("家計簿ID: \(householdID)")
                .font(.headline)
                .padding(.top)

            // パスワード入力
            SecureField("パスワード（8文字以上）", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // 作成ボタン
            Button("作成する") {
                guard password.count >= 8 else {
                    errorMessage = "パスワードは8文字以上にしてください"
                    return
                }

                // Firestoreで家計簿IDがユニークか確認
                FirebaseManager.shared.isHouseholdIDUnique(String(householdID)) { isUnique in
                    if isUnique {
                        // 家計簿を作成する処理
                        FirebaseManager.shared.createHousehold(id: String(householdID), password: password) { error in
                            if error == nil {
                                // 家計簿の作成成功後、ホーム画面に移動
                                isJoined = true
                                navigateToHome()
                            } else {
                                errorMessage = "エラーが発生しました。再試行してください。"
                            }
                        }
                    } else {
                        errorMessage = "指定されたIDは既に使用されています。別のIDを試してください。"
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(password.count < 8) // パスワードが8文字未満の場合ボタンを無効化

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
    
    // ホーム画面への遷移処理
    private func navigateToHome() {
        // ここでホーム画面への遷移処理を行います
        // 通常はNavigationLinkやProgrammatic Navigationで画面遷移を行いますが、詳細は以下に記載します
        // ここでは仮の遷移処理として、isJoinedをtrueにして画面を更新しています
    }
}

