import SwiftUI
import FirebaseAuth
import Combine

extension Color {
    static let offwhite = Color(red: 0.95, green: 0.95, blue: 0.95)
}

struct AddExpenseView: View {
    @State private var date = Date()
    @State private var memo = ""
    @State private var amount = ""
    @State private var selectedCategory = "食費"
    @State private var selectedPerson = ""
    @State private var paymentType = "割り勘"
    @AppStorage("householdID") private var savedHouseholdID = ""
    @AppStorage("user1Name") private var user1Name: String = "Person 1"
    @AppStorage("user2Name") private var user2Name: String = "Person 2"
    let categories = ["食費", "交通費", "趣味", "その他"]
    let paymentTypes = ["割り勘", "立て替え", "精算"]
<<<<<<< HEAD
=======
    // `members`は計算プロパティで定義
>>>>>>> 9c75a31a186f211eb266a98c6158c47406e80654
    var members: [String] {
        [user1Name, user2Name]
    }

    @Environment(\.dismiss) private var dismiss
    @State private var keyboardHeight: CGFloat = 0
    @State private var keyboardPublisher: AnyCancellable?


    var body: some View {
        ZStack{
            Color.offwhite
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
<<<<<<< HEAD
=======
                    // 画面をタップしたらキーボードを閉じる
>>>>>>> 9c75a31a186f211eb266a98c6158c47406e80654
                    hideKeyboard()
                }
            VStack(spacing: 20) {
                DatePicker("日付", selection: $date, displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                
                HStack{
                    Picker("カテゴリ", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category)
                                .foregroundStyle(.black)
                        }
                    }
<<<<<<< HEAD
=======
                    .pickerStyle(MenuPickerStyle())
>>>>>>> 9c75a31a186f211eb266a98c6158c47406e80654
                    .padding(8)
                    .background(Color.orange)
                    .cornerRadius(10)
                    TextField("金額", text: $amount)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Text("円")
                }

                Text("支払いの種類")
                HStack {
                    ForEach(paymentTypes, id: \.self) { pType in
                        Button(action: {
                            // ボタンが押されたら選択された人を変更
                            paymentType = pType
                        }) {
                            Text(pType)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(paymentType == pType ? Color.orange : Color.gray.opacity(0.3))
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }
                    }
                }
                Text("払った人")
                HStack {
                    ForEach(members, id: \.self) { person in
                        Button(action: {
                            // ボタンが押されたら選択された人を変更
                            selectedPerson = person
                        }) {
                            Text(person)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(selectedPerson == person ? Color.orange  : Color.gray.opacity(0.3))
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }
                    }
                }
                
                TextField("メモ", text: $memo)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    saveExpenseData()
                }){
                    ZStack {
                        Color.yellow
                            .frame(width: 160, height: 60)
                            .cornerRadius(10)
                        Text("保存する")
                            .font(.system(size: 25))
                            .foregroundStyle(.black)
                    }
                }
                Spacer()
            }
            .padding()
            .navigationTitle("出費の追加")
            .offset(y: -adjustedKeyboardOffset())
            .animation(.easeOut, value: keyboardHeight)
        }
        .onAppear {
            startObservingKeyboard()
        }
        .onDisappear {
            stopObservingKeyboard()
        }
    
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
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func adjustedKeyboardOffset() -> CGFloat {
            let screenHeight = UIScreen.main.bounds.height
            return min(keyboardHeight, screenHeight * 0.1) // 高さの最大を画面の40%に制限
        }
    
    private func startObservingKeyboard() {
        let notificationCenter = NotificationCenter.default
        keyboardPublisher = Publishers.Merge(
            notificationCenter.publisher(for: UIResponder.keyboardWillShowNotification),
            notificationCenter.publisher(for: UIResponder.keyboardWillHideNotification)
        )
        .compactMap { notification -> CGFloat? in
            guard let userInfo = notification.userInfo,
                  let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return nil
            }
            return notification.name == UIResponder.keyboardWillShowNotification ? endFrame.height : 0
        }
        .assign(to: \.keyboardHeight, on: self)
    }

    private func stopObservingKeyboard() {
        keyboardPublisher?.cancel()
    }
}
