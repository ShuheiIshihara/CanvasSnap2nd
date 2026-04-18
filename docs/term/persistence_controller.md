## PersistenceController

### 概要
Core Data フレームワークにおいて、データベース操作に必要な NSPersistentContainer と関連コンポーネント群を初期化・管理するシングルトン構造体。アプリケーション全体でデータ永続化機能を統一的に提供し、SwiftUI の環境統合を容易にするための Wrapper として機能する。

### 仕組み・動作原理
PersistenceController は以下の処理フローで動作する：

1. **初期化時** — NSPersistentContainer を生成し、Core Data モデルファイル（.xcdatamodeld）をロード
2. **ストア読み込み** — loadPersistentStores() で既存のデータベースファイルを読み込むか、なければ新規作成
3. **コンテキスト設定** — container.viewContext（NSManagedObjectContext）を SwiftUI 環境に注入
4. **変更の自動統合** — automaticallyMergesChangesFromParent で並行アクセス時の競合を解決

実装例では、inMemory フラグでテスト用メモリ内ストアを作成できるほか、@MainActor 属性で preview 環境用のサンプルデータセットを提供している。

### 主な用途・ユースケース
- **アプリ起動時の Core Data 初期化** — モデル定義の読み込みとデータベース接続確立
- **SwiftUI View での操作** — @Environment(\.managedObjectContext) で Fetch や Create/Update/Delete を実行
- **Preview キャンバスのテスト** — メモリ内ストアで UI プレビューを軽量に検証
- **シングルトン として統一管理** — PersistenceController.shared を経由して全箇所で共通のコンテキストを参照

### 関連技術・概念
- **NSPersistentContainer** — Core Data スタック全体をカプセル化する Apple 提供クラス
- **NSManagedObjectContext** — Core Data エンティティを操作するメモリ上の作業領域
- **NSPersistentStoreCoordinator** — データベースファイルの読み書きを仲介
- **@FetchRequest** — SwiftUI で Core Data クエリを宣言的に実行する機構
- **NSManagedObjectModel** — エンティティ定義とリレーション情報を保持
- **Codable** との併用（代替案）— JSON シリアライゼーション ベースのデータ永続化

---

📊 **トークン使用記録**
- モデル: claude-haiku-4-5-20251001
- トークン合計: 20043
- 実行時間: 30196 ms
