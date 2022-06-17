import Foundation

class KeyValueStorage {
    func save<T>(_ data: T, forKey key: String) where T : Decodable, T : Encodable {
        do {
            let encodedData = try JSONEncoder().encode(data)
            UserDefaults.standard.set(encodedData, forKey: key)
        } catch {
            logger.log(level: .error, message: "KeyValueStorage \(self): save error")
        }
    }
    
    func get<T>(_ dataType: T.Type, forKey key: String) -> T? where T : Decodable, T : Encodable {
        do {
            if let encodedData = UserDefaults.standard.data(forKey: key) {
                return try JSONDecoder().decode(T.self, from: encodedData)
            }
        } catch {
            logger.log(level: .error, message: "KeyValueStorage \(self): get error")
        }
        return nil
    }
}

class RickAndMortyStorage {
    static let shared = RickAndMortyStorage()
    private let keyValueStorage: KeyValueStorage = KeyValueStorage()
    private let favoutitesKey = "favourites"
    private let recentlySearchedKey = "recentlySearched"
    
    func clearFavourites() async throws {
        keyValueStorage.save([Character](), forKey: favoutitesKey)
    }
    
    func getFavourites() async throws -> [Character] {
        return keyValueStorage.get([Character].self, forKey: favoutitesKey) ?? []
    }
    
    func isFavourite(character: Character) async throws -> Bool {
        return try await getFavourites().contains(character)
    }
    
    func saveFavouriteCharacter(isFavorite: Bool, character: Character) async throws {
        var favourites: [Character] = try await getFavourites()
        if let index = favourites.firstIndex(of: character) {
            if (!isFavorite) {
                favourites.remove(at: index)
            }
        } else {
            if (isFavorite) {
                favourites.append(character)
            }
        }
        keyValueStorage.save(favourites, forKey: favoutitesKey)
    }
    
    func clearRecent() async throws {
        keyValueStorage.save([Character](), forKey: recentlySearchedKey)
    }
    
    func getRecentlySearched() async throws -> [Character] {
        return keyValueStorage.get([Character].self, forKey: recentlySearchedKey) ?? []
    }
    
    func addRecentlySearchedCharacter(_ character: Character) async throws {
        var recentlySearched: [Character] = try await getRecentlySearched()
        if let index = recentlySearched.firstIndex(of: character) {
            recentlySearched.remove(at: index)
        }
        recentlySearched.append(character)
        keyValueStorage.save(recentlySearched, forKey: recentlySearchedKey)
    }
}
