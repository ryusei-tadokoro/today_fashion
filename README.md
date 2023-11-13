# tofa

## サービス概要
tofa(today fashion)とは
今持っている服装やアクセサリー等を管理し、
その中で気温や自分の体調に合わせてコーディネートをしてくれるサービスです。

##　想定されるユーザー層
- 当日服装選びに時間をかけてしまう人
- 服購入に後悔したことがある人
- 当日着る服を間違えて、暑い寒い思いをしたことがある人
- 女性向けの服装管理アプリが多いことから、男性でも使えるようなアプリが欲しい人

## サービスコンセプト
服装選びに時間をかけたくない、服購入に失敗したくないことから、
服を管理し、持っている服からその日の気温や湿度、
または自分の体調に合わせて自動的に決めてくれるアプリを考案しました。

天気アプリにて、今日の服装指数を見ることはできます。
また、競合アプリを精査していると、体感温度について考慮されてはいませんでした。
ここでいう体感温度とは
寒がりもしくは冷え性の人、暑がりの人
湿度が高くて暑く感じやすい人、冷房が効きすぎて苦手な人などを指します。

また、住んでいる地域は選択できるものの、移動先（旅行先や職場など）について問われていませんでした。
私は神奈川出身で高校は川崎北部の実家から小田原まで通学していました。
市街地から山や川が流れている田舎の学校に通っていたので、
秋から春の間の昼と夜では気温差が激しく、体調を崩しやすかったです。

さらに、最近でも服を購入する際、似たような色柄のシャツを買って後悔したこともあります。
サイズについても、誤ったことがあります。
そのことから、服の購入日、サイズや色など購入した服の詳細について記録できると不要な買い物のリスクを減らせると思います。
しかし、毎回手入力を行うと億劫になるので、簡易的に入力できれば使いやすくなると思いました。

このような詳細を入力する手間を省くために、OCRを使った画像分析にて購入した服のレシートあるいは服自体をカメラに通すことによって自動入力ができる機能や、Amazonなどオンラインショップにて購入した際に商品情報を使って自動入力する機能、もしくは、カメラを使用せずアイコンにて登録ができる機能を考えています。

以上のことから
気温によって服を間違いたくない x 服装選びに時間を取られたくない x クローゼットの可視化 
３点をメインターゲットとしてサービスを提供したいと思います。

## 実装を予定している機能
### MVP
* 今日の天気と気温および服装指数表示機能
　　※ログインなしの場合のトップ画面に配置。全国の天気や気温・服装指数が確認可能な機能とする。
　　※OpenWeatherMapもしくはWeather APIを導入して、天気や気温情報を取得します
* ユーザー管理
　*ユーザー登録
　　＊体感温度設定（必須 選択式 暑がり・やや暑がり・標準・やや寒がり・寒がり）
　　＊住んでいる地域の選択(必須 選択式)
　　＊よく使う地域の選択(任意)
　＊ログイン
　＊ログアウト
　＊ユーザー詳細
　　＊ユーザー登録と同じ
* ユーザー登録後の今日の天気および服装指数表示機能
　※ログイン後のトップ画面。ユーザー登録に基づいて服装を表示してくれる。コーディネート提案ロジックとしてはアルゴリズムを実装する。
（提案される服装は、体感温度および気温によって調整されます。服装ごとに予め設定された数値（例えば、T-シャツなら合計値32度、薄手の長袖なら28度）に基づき、体感温度と気温の合計値によって服装が選定される予定です。例えば、体感温度を暑い（高い）と設定し、その日の気温が30度だった場合、合計値は32度となります。この場合、T-シャツが提案されます。今後はユーザーのフィードバックを取り入れて調整を行う予定です。）
　※コーディネートの表現部分はデフォルトで用意したアイコンにて表現する。別途同じ表示画面に、登録した服が３着以上になったら追加で表現する（満たない場合は『３着以上登録してください』と表示する）
* 服管理
　＊服一覧 #クローゼット可視化の主な機能
　　＊検索機能
　　　＊季節（服登録時に紐付く）
　　　＊種類別(服登録時に紐づく)
　＊服の登録
　　*自動入力（任意 服の写真もしくはアイコン選択　服の名前　服の種類の３項目を自動入力）
　　　＊画像分析(TesseractもしくはGoogle Cloud Vision APIを使用予定)
     *オンラインショップでの購入（Amazon Product Advertising APIやRakuten Web Serviceを使用予定）
　　＊服の写真もしくはアイコン選択（必須 写真の登録が手間な場合、服の種類選択後デフォルトでアイコンを表示）
     *写真の場合、CarrierWave、MiniMagickを実装予定。画像のリサイズ、画像データの容量制限するため
     *アイコンの場合、アイコンの選択(服の色を選択) 
　　*服の名前（必須 :string型にしてフリー入力にする）
　　＊服の種類（必須 選択式にする（Yシャツなら　厚手、薄着など））
　　＊服の備考欄（任意）
　　　＊購入日
　　　＊サイズ
　　　＊購入場所
　　　＊値段
　　　＊使用頻度
　　　＊季節 #購入した服の適正時期
　　　＊その他コメント
　　＊服の編集 #追加編集が必要な場合に使用する
　　　※登録した服と同じ内容
　　＊admin機能
* 通知設定
　※当日の天気と気温・傘の有無を通知でお知らせ
　※服装指数を（登録した服もしくは登録数が少ない場合はデフォルトで用意した服でコーディネートして）お知らせする（LINE Messaging API・LINE Messaging API SDK for Rubyを使ってプッシュ通知）
　* 問い合わせ #特に体感温度につていて数値など

### その後の機能
* その他地域登録 #旅行など、普段行かない所に訪れる場合に使用。
　＊地域設定
　＊期間設定
* 購入する服の診断 #過去の登録履歴やアンケートによって好みを分析して、次回買うべき服を提案する。(似たような服を購入防止案)

画面遷移図
https://www.figma.com/file/Hm71hKfu2xKw8ZEEW5JY6O/%E7%94%BB%E9%9D%A2%E9%81%B7%E7%A7%BB%E5%9B%B3_today_fashion(Tofa)?type=design&node-id=0%3A1&mode=design&t=lPEL6XUFxWH5Dodx-1

E-R図
https://i.gyazo.com/4fa7e33f7a9ad6e122d700adbb9acb1a.png
