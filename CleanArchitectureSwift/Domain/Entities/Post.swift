// モデルクラスみたいなもの
// Post型の定義
struct Post: Codable, Identifiable {
    let id: Int
    let title: String
    let body: String
}
