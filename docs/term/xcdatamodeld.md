## .xcdatamodeld

### 概要

`.xcdatamodeld` は Xcode の Core Data モデルバンドルの拡張子で、iOS・macOS アプリケーションのデータベーススキーマを定義する専用ファイルです。Xcode の組み込みモデルエディタで編集でき、アプリケーション内のエンティティ（データベーステーブル）、属性（カラム）、関係（リレーションシップ）を管理します。

### 仕組み・動作原理

`.xcdatamodeld` は「Core Data Model Bundle」と呼ばれるディレクトリで、バージョン管理が可能な構造になっています。内部には以下の要素が含まれます：

- 複数のバージョン（`VersionName.xcdatamodel` ファイル）
- 各バージョン内の Contents.xml（XML 形式のモデル定義）
- バージョン情報を記載した Info.plist ファイル

Xcode のビルド時に `.xcdatamodeld` は runtime format にコンパイルされ、`.momd` 拡張子のファイルパッケージに変換されます。このコンパイル済みモデル（`.momd`）が実行時に Core Data フレームワークによって読み込まれ、データの永続化と管理が行われます。

Xcode の Data Model Editor では、テーブルビュー（エンティティの追加編集）とグラフビュー（リレーションシップの可視化）の両モードで編集できます。

### 主な用途・ユースケース

- iOS・macOS アプリケーションの永続的なデータストア設計
- Core Data を使用したデータベース管理
- マイグレーション対応時の複数バージョン管理
- エンティティ間のリレーションシップ定義

### 関連技術・概念

- **Core Data**: Apple 純正の ORM・データ永続化フレームワーク
- **.momd ファイル**: コンパイル済みの runtime model
- **.mom ファイル**: 個別のコンパイル済みモデルファイル
- **Data Model Editor**: Xcode 組み込みの視覚的エディタ（Xcode 14 以降で改良版が導入）
- **モデルのバージョニング**: マイグレーション時の旧バージョン保持

### 参照ソース

- [Designing a Core Data model - Hacking with Swift](https://www.hackingwithswift.com/read/38/2/designing-a-core-data-model)
- [Core Data Part 1 Components of Core Data - Data Model - DEV Community](https://dev.to/simrandotdev/core-data-part-1-components-of-core-data-data-model-3de0)
- [Creating a Core Data model - Apple Developer Documentation](https://developer.apple.com/documentation/coredata/creating-a-core-data-model)
- [Model File Format and Versions - Apple Developer Documentation](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreDataVersioning/Articles/vmModelFormat.html)

---
📊 **トークン使用記録**
- モデル: claude-haiku-4-5-20251001
- トークン合計: 20734
- 実行時間: 31195 ms
