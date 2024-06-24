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
