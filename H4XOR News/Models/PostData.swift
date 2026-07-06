import Foundation

struct Results: Decodable {
    let hits: [Post]
}

struct Post: Decodable, Identifiable {
    var id: String { objectID }

    let points: Int
    let title: String
    let url: String?

    let objectID: String
}
