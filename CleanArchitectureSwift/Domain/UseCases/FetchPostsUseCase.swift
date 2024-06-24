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
