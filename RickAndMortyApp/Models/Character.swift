import Foundation

struct Character: Codable, Equatable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let gender: String
    let image: String
    
    func imageURL() -> URL? {
        return URL(string: image)
    }
}
