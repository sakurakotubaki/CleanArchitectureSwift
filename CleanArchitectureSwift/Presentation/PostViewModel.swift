import Foundation

// ViewModel
class PostViewModel: ObservableObject {
    @Published var posts: [Post] = []
    private var useCase: FetchPostsUseCase
    
    init(useCase: FetchPostsUseCase) {
        self.useCase = useCase
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
                print("Error: \(error)")
            }
        }
    }
}
