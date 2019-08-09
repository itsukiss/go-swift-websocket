# Getting Started
1. `ios-client-sample/ios-client-sample.xcworkspace`を実行
2. golangの実行環境を準備
3. `local-server-sample/starscream-server/starscream-server.go`を実行（socket.ioを試したい場合はsocket.io側）
4. xcodeの実行プログラム側で`connect starscream`をタップ
5. `---starscream is connected---`が表示されたら接続成功
6. `send`ボタンをタップするとResponseが返却され表示される

備考：socket.io側はProtobufを使ってないです。

Protobufのファイルの生成方法は下部参照

# ライブラリ選定理由
## クライアント側のライブラリは[Starscream](https://github.com/daltoniam/Starscream)
- objective-cで作成されていてあまりメンテナンスされていないSocketRocketは除外
- socket.ioはサーバ側の言語がGolang非対応なのでsocket.io-client-swiftもなし
- StarscreamとSwiftWebsocketはあまり変わらないが、人気度と知見の量的にStarscream（参考：https://ios.libhunt.com/compare-starscream-vs-swiftwebsocket?rel=cmp-cmp）

## サーバ側は[gorilla/websocket](https://github.com/gorilla/websocket)
- 標準パッケージである https://godoc.org/golang.org/x/net/websocket に下記のように書いてある
> This package currently lacks some features found in an alternative and more actively maintained WebSocket package:
https://godoc.org/github.com/gorilla/websocket

下記を見ればわかるように標準の方が機能が多く不足しているため
<table>
<tr>
<th></th>
<th><a href="http://godoc.org/github.com/gorilla/websocket">github.com/gorilla</a></th>
<th><a href="http://godoc.org/golang.org/x/net/websocket">golang.org/x/net</a></th>
</tr>
<tr>
<tr><td colspan="3"><a href="http://tools.ietf.org/html/rfc6455">RFC 6455</a> Features</td></tr>
<tr><td>Passes <a href="https://github.com/crossbario/autobahn-testsuite">Autobahn Test Suite</a></td><td><a href="https://github.com/gorilla/websocket/tree/master/examples/autobahn">Yes</a></td><td>No</td></tr>
<tr><td>Receive <a href="https://tools.ietf.org/html/rfc6455#section-5.4">fragmented</a> message<td>Yes</td><td><a href="https://code.google.com/p/go/issues/detail?id=7632">No</a>, see note 1</td></tr>
<tr><td>Send <a href="https://tools.ietf.org/html/rfc6455#section-5.5.1">close</a> message</td><td><a href="http://godoc.org/github.com/gorilla/websocket#hdr-Control_Messages">Yes</a></td><td><a href="https://code.google.com/p/go/issues/detail?id=4588">No</a></td></tr>
<tr><td>Send <a href="https://tools.ietf.org/html/rfc6455#section-5.5.2">pings</a> and receive <a href="https://tools.ietf.org/html/rfc6455#section-5.5.3">pongs</a></td><td><a href="http://godoc.org/github.com/gorilla/websocket#hdr-Control_Messages">Yes</a></td><td>No</td></tr>
<tr><td>Get the <a href="https://tools.ietf.org/html/rfc6455#section-5.6">type</a> of a received data message</td><td>Yes</td><td>Yes, see note 2</td></tr>
<tr><td colspan="3">Other Features</tr></td>
<tr><td><a href="https://tools.ietf.org/html/rfc7692">Compression Extensions</a></td><td>Experimental</td><td>No</td></tr>
<tr><td>Read message using io.Reader</td><td><a href="http://godoc.org/github.com/gorilla/websocket#Conn.NextReader">Yes</a></td><td>No, see note 3</td></tr>
<tr><td>Write message using io.WriteCloser</td><td><a href="http://godoc.org/github.com/gorilla/websocket#Conn.NextWriter">Yes</a></td><td>No, see note 3</td></tr>
</table>

# WebSocket Client ライブラリ比較
## Starscream 
### レポジトリ情報
- https://github.com/daltoniam/Starscream
- ★5,106
- 最終更新日: 3ヶ月前
- Swift
- Objective-Cは[Jetfire](https://github.com/acmacalister/jetfire)
- framework size: 942KB
- first commit: Commits on Jul 17, 2014

### メリット
- サーバ側が通常のwebsocketが使える
- 軽量

### デメリット
- websocketが繋がらない場合にpollingなどをする場合自前で書かなければならない

## Socket.io-client-swift
### レポジトリ情報
- https://github.com/socketio/socket.io-client-swift
- ★3,797
- 最終更新日: 2ヶ月前
- Swift
- Objective-cからでも使える
- framework size: 1.4MB
- 内部的にStarscreamを使っている。
- websocketのライブラリではなくsocket.ioのライブラリ（https://github.com/socketio/socket.io-client--swift/blob/6cfea5aca32bd1ebafccc4c4f1fb7f71e1b2e9ce/Usage%20Docs/FAQ.md)

### 仕様
- Clientでこれを使う場合、Serverもsocket.ioは必須っぽい（内部的にsocketURLなどに/socket.io/のpathなどが付与されている）

### メリット
- socket.ioが使える
    - `WebSocket`が繋がらなかった時に代替手段として`Long Polling`や`polling`を行ってくれる
- objective-cでも使える

### デメリット
- サーバ側もsocket.ioを使わなければならない
    - socket.ioはもともと`node.js用サーバー側ライブラリとブラウザ用JavaScriptライブラリのセット`なのでgolangでのsupportがない。一応[go-socket.io](https://github.com/googollee/go-socket.io)というライブラリがあるが、現状でsocket.ioのversion1.4までしかsupportしていない

## SwiftWebSocket
### レポジトリ情報
- https://github.com/tidwall/SwiftWebSocket
- ★1,262
- 最終更新日: 3ヶ月前
- Swift
- Objective-cでも使える
- first commit: May 27, 2015

### メリット
- Starscream同様
- Objective-cでも使える

### デメリット
- 知見が少ない

## SocketRocket
### レポジトリ情報
- https://github.com/facebook/SocketRocket
- ★8,660
- 最終更新日: 1年前
- Objective-C

### メリット
- 知見が多い

### デメリット
- コードがほぼobjective-cであるため内部実装が読みにくい

# ProtocolBufferについて
## 概要
[こちら](https://qiita.com/yugui/items/160737021d25d761b353)を読んでもらえば大体こんな感じかっていうのは理解できる。
要約すると下記のような感じで書いている
```
Protocolbufferはスキーマ言語でGoogleが内部で利用しているシリアライゼーション形式である。
スキーマ言語がなぜ今人気になった理由は、単一のDBなどにデータを保存していたような昔と違い、
データはあちこちのいろんなストレージ技術で保存されたり、バックエンドも単一サービスではなくて分割されていたりする。
また、クライアントもweb版, iOS版, Android版それぞれ別の言語で実装されていたりするからだ。
JSON schemeは可読性に難がある。

Protobufがいい理由は簡素で可読で、割と何にでも使えて、しかしすべてをカバーしようとして膨れあがっておらず、ツールを拡張可能。
とりわけ何かがすごく良いという訳でもないけれども、すこし使い込めばこの素朴さが手に馴染みやすい。
```
## 導入にあたって
### メリット
- サーバ側クライアント側で余計なすり合わせが発生しにくい
- バイナリデータでやりとりするので軽量

### デメリット
- デバッグは少しやりにくい
- 導入が少し手間がかかる

## 定義
`message [モデル名] {
    TYPE NAME = UNIQUE NUMBER
}
`
といった書き方をする。
下記のように定義する。
```
syntax = "proto3";

message User {
    int32 id = 1;
    string name = 2;
}
```


## 導入手順

### 共通
- protocolbufferをinstallする
```
$ brew install protobuf
```
---
### client側（swift）
1. swift-protobufをinstall
```
$ brew install swift-protobuf
```
2. ファイルの書き出し
```
$ protoc --swift_out={outputのpath} exsample.proto
```
3. 書き出したファイルをxcode.projectに追加
4. swift-protobufをpod install
```
pod 'SwiftProtobuf', '~> 1.0'
```
5. structとして使える
```swift
guard let user = try? User(serializedData: data) else { return }
```
---
### server側（golang）
1. protoc-gen-goをinstall
```
$ go get -u github.com/golang/protobuf/{proto,protoc-gen-go}
```
2. ファイルの書き出し
```
$ protoc --go_out={outputのpath} exsample.proto
```
3. goファイルが書き出されるのでgo側からimportすれば、定義モデルが使える

## 参考
- https://qiita.com/pelican/items/0df8084e0a0f6f183636
- https://qiita.com/tkmn0/items/7208c880693e63ca247a
- https://qiita.com/yugui/items/160737021d25d761b353
- https://qiita.com/takusemba/items/05a4431114f0c6fee3d9
