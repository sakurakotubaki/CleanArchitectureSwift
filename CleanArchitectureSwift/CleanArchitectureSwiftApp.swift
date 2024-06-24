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
