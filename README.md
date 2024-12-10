# README

# ふたりの家計簿
手軽に使用できることに特化した二人用家計簿です。</br>
firebaseを用いたデータ管理により, ユーザ間での操作が同期されます。</br>
<div style="display: flex; justify-content: space-between;">
  <img src="https://github.com/user-attachments/assets/c8a847e6-c033-4e26-b839-d56eb8c60250" width="22%" />
  <img src="https://github.com/user-attachments/assets/03771b96-c890-4708-979e-e874870fb4c4" width="22%" />
  <img src="https://github.com/user-attachments/assets/82ebaba5-5579-46ac-85b3-5870884963af" width="22%" />
  <img src="https://github.com/user-attachments/assets/bfa6ab4a-7db3-44ad-a339-d8e7a6b966ef" width="22%" />
</div>

# 公開場所
現在TestFlightへの公開に向け手続き中です。

# 使用技術
+ Swift 5.10
+ Xcode 16.1
+ Firebase

# 機能一覧
+ ホーム画面
  + ユーザー間の支払金額の差異を表示
+ 支出登録画面
  + 日付, カテゴリ, 金額, 支払いの種類, 払ったユーザーを指定と保存
+ 履歴画面
  + 登録した支出一覧の表示
  + 登録した支出の編集
+ オプション画面
  + 使用中の家計簿IDの確認
  + 名前の設定・変更（変更時には, 履歴上の名前も置き換え）
  + 支出履歴のcsvファイル出力
  + ログアウト
+ 家計簿作成画面
  + 家計簿IDの生成, パスワードの設定
+ 家計簿への参加画面
  + 家計簿ID, パスワードの入力で家計簿への参加

# テスト
+ Xcode 16.1
