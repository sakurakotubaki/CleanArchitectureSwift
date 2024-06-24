
# Swiftで　CleanArchitectureぽくしてみた
クラスでなくて、構造体の責務を分けるのが今回やっていることです。

## やったこと
HTTP GETして、Viewにデータを表示するだけですが、ロジックとViewを切り分けるだけでなく、他のロジックを作ったら取り替えることをできるようにしたり、特定の構造体に依存した関係をもたないように工夫しています。

今回はこのようなフォルダ構成になっております
![alt text](<スクリーンショット 2024-06-24 21.48.54.png>)


海外の人やネットの情報を参考に作ったのですが、今回はDataというレイヤーはありません。DBを使いませんし書く機会がないので、省きました。もしかしたら良くないかも？

| ディレクトリ       | 役割                                                                      |
| ------------ | ----------------------------------------------------------------------- |
| Presentation | 画面を作るViewのコードと、Viewの状態を管理するViewModelのコードを配置する。                               |
| Domain       | モデルとなるEntities、ロジックが実装されているRepository、RepositoryをDIして、受け取るUseCaseを配置する。 |

REST APIに合わせて作成して、モデルとなるstruct 構造体。他の言語だったら、モデルクラスを作りますかね。

```swift
// モデルクラスみたいなもの

// Post型の定義

struct Post: Codable, Identifiable {

    let id: Int

    let title: String

    let body: String

}
```

struct Postを配列のデータ型にしたRepositoryを定義します。protocolを作成して、これ実装した struct にAPIと通信するロジックを実装します。

```swift
import Foundation
// PostsRepository プロトコル
// プロトコルは、メソッドやプロパティの宣言をまとめたもの
// これをクラスで例えると、抽象クラスのようなもの
protocol PostsRepository {
    func fetchPosts() async throws -> [Post]
}

// これは、クラスで例えると、実装した抽象クラスのようなもの
// PostsRepository の具体的な実装
// この実装は、APIからデータを取得する
struct PostsRepositoryImpl: PostsRepository {
    func fetchPosts() async throws -> [Post] {
        // guard let は、Optionalの値がnilでない場合に、値を取り出して処理を続けるための構文
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
        // URLError(.badURL) は、URLが不正な場合に発生するエラー
            throw URLError(.badURL)
        }
        // URLSession.shared.data(from: url) は、URLからデータを取得する非同期処理
        let (data, _) = try await URLSession.shared.data(from: url)
        // JSONDecoder().decode([Post].self, from: data) は、JSONデータをPostの配列に変換する処理
        return try JSONDecoder().decode([Post].self, from: data)
    }
}
```

UseCasesは、ロジック自体は持たず、PostsRepositoryをDIして、使っています。外部のインスタンス化された構造体を受け取る。他のロジックに取り替えたい時は、ここで別の機能を実装している構造体に変更する。execute() メソッドは、ViewModelで使うために使用。

```swift
import Foundation

// FetchPostsUseCase プロトコル
// このプロトコルは、FetchPostsUseCase の実装クラスに必要なメソッドをまとめたもの
protocol FetchPostsUseCase {
    func execute() async throws -> [Post]
}

// GetPostsUseCase の実装
// このクラスは、FetchPostsUseCase プロトコルを実装している
struct GetPostsUseCase: FetchPostsUseCase {
    // PostsRepository プロトコルを実装した PostsRepositoryImpl のインスタンスを保持する
    private let repository: PostsRepository
    // PostsRepositoryImpl のインスタンスを引数に取るイニシャライザ
    init(repository: PostsRepository) {
        self.repository = repository
    }
    // execute() メソッドは、非同期処理で投稿データを取得する
    // execute() メソッド自体は、ロジックを持たず、repositoryが、ロジックを持つ
    func execute() async throws -> [Post] {
        return try await repository.fetchPosts()
    }
}
```

Presentationは、画面であるViewと画面の状態を管理するViewModelを配置します。　

ViewModelには、通信のエラーが出た時の処理と、SwiftUIだと、`ObservableObject`で状態管理をするので、クラスに継承させています。C#とか、Kotlinみたいに、`:`をつけて、スーパークラスの継承やプロトコルの継承をします。構造体だと継承はできないので、準拠させることしかしない。

今回のコードだと、エラー処理は足りないと思いますが、こんな感じで書いてみました。

```swift
import Foundation

enum HTTPError: Error {
    case serverError
}

// ViewModel
class PostViewModel: ObservableObject {
    @Published var posts: [Post] = []// Post の配列を保持するプロパティを追加
    @Published var error: HTTPError? // エラー情報を保持するプロパティを追加
    // FetchPostsUseCase のインスタンスを保持するプロパティを追加
    private var useCase: FetchPostsUseCase
    // FetchPostsUseCase のインスタンスを引数に取るイニシャライザ
    init(useCase: FetchPostsUseCase) {
        // イニシャライザで FetchPostsUseCase のインスタンスを保持する
        self.useCase = useCase
        // fetchPosts() メソッドを呼び出す
        fetchPosts()
    }

    func fetchPosts() {
        Task {
            do {
                let posts = try await useCase.execute()
                DispatchQueue.main.async {
                    self.posts = posts
                }
            } catch {
                DispatchQueue.main.async {
                    // ここでエラーの種類に応じて適切なエラーを設定
                    if let httpError = error as? HTTPError {
                        self.error = httpError
                    } else {
                        self.error = .serverError
                    }
                }
            }
        }
    }
}
```

HTTP GETに成功するとこちらのコードに、APIから取得したデータを表示することができます。
```swift
import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel: PostViewModel
    
    init(useCase: GetPostsUseCase) {
        self.viewModel = PostViewModel(useCase: useCase)
    }
    
    var body: some View {
        List(viewModel.posts) { post in
            VStack(alignment: .leading) {
                Text(post.title)
                    .font(.headline)
                Text(post.body)
                    .font(.subheadline)
            }
        }
    }
}
```

ContentViewは引数を受け取っているので、渡してあげないとエラーが出てしまいます。インスタンス化しているエントリーポイントのファイルで、DIしてあげれば完成です。

```swift
import SwiftUI

@main
struct CleanArchitectureSwiftApp: App {
    // 外部の依存を注入
    let useCase = GetPostsUseCase(repository: PostsRepositoryImpl())
    var body: some Scene {
        WindowGroup {
            // イニシャライザで依存を注入
            // 他の言語だったら、コンストラクタ引数に渡すと表現しますね。
            ContentView(useCase: useCase)
        }
    }
}
```