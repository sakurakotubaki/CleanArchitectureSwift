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
