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
