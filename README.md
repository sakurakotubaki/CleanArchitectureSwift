
# Swiftで　CleanArchitectureぽくしてみた
クラスでなくて、構造体の責務を分けるのが今回やっていることです。

## やったこと
HTTP GETして、Viewにデータを表示するだけですが、ロジックとViewを切り分けるだけでなく、他のロジックを作ったら取り替えることをできるようにしたり、特定の構造体に依存した関係をもたないように工夫しています。

今回はこのようなフォルダ構成になっております

![スクリーンショット 2024-06-24 21 30 51](https://github.com/sakurakotubaki/CleanArchitectureSwift/assets/73347485/5cb657b9-69c7-4df4-a530-38a398a1d3fd)

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
