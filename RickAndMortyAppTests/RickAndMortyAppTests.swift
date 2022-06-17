import XCTest
@testable import RickAndMortyApp

class RickAndMortyAppFavouritesTests: XCTestCase {
    let character: Character = Character(id: 1, name: "Rick Sanchez", status: "Alive", species: "Human", gender: "Male", image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")
    
    override func setUp() async throws {
        try await RickAndMortyStorage.shared.clearFavourites()
    }
    
    func testFavourites() async throws {
        var trueCharacters: [Character] = try await RickAndMortyStorage.shared.getFavourites()
        trueCharacters.append(character)
        try await RickAndMortyStorage.shared.saveFavouriteCharacter(isFavorite: true, character: character)
        let storageCharacters = try await RickAndMortyStorage.shared.getFavourites()
        return XCTAssertEqual(trueCharacters, storageCharacters)
    }
    
    func testDislikeFavourites() async throws {
        try await RickAndMortyStorage.shared.saveFavouriteCharacter(isFavorite: true, character: character)
        var storageCharacters = try await RickAndMortyStorage.shared.getFavourites()
        XCTAssertEqual([character], storageCharacters)
        try await RickAndMortyStorage.shared.saveFavouriteCharacter(isFavorite: false, character: character)
        storageCharacters = try await RickAndMortyStorage.shared.getFavourites()
        return XCTAssertEqual([], storageCharacters)
    }
    
    override func tearDown() async throws {
        try await RickAndMortyStorage.shared.clearFavourites()
    }
}
