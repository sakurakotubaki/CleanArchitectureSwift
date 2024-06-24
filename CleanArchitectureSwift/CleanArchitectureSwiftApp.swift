import SwiftUI

@main
struct CleanArchitectureSwiftApp: App {
    let useCase = GetPostsUseCase(repository: PostsRepositoryImpl())
    var body: some Scene {
        WindowGroup {
            ContentView(useCase: useCase)
        }
    }
}
