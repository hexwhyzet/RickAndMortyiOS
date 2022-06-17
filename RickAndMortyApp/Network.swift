//
//  Network.swift
//  RickAndMortyApp
//
//  Created by Ваня on 12.06.2022.
//

import Foundation
import os.log


class Results: Codable {
    var results: [Character]
}


class RickAndMortyApi {
    static let shared = RickAndMortyApi()
    private let baseURL: String = "https://rickandmortyapi.com/api"
    
    func searchCharacter(prefix: String, completion: @escaping ([Character]) -> Void) {
        guard let url = URL(string: baseURL + "/character?name=\(prefix.replacingOccurrences(of: " ", with: "%20"))") else {
            logger.log(level: .error, message: "Invalid URL")
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        logger.log(level: .info, message: "Request: " + baseURL + "/character?name=\(prefix)")
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
            guard let data = data else {
                logger.log(level: .error, message: "URLSession dataTask error: \(String(describing: error))")
                return
            }
            
            do {
                let characters = try JSONDecoder().decode(Results.self, from: data)
                completion(characters.results)
            } catch {
                logger.log(level: .error, message: "JSONSerialization error: \(String(describing: error))")
                completion([])
            }
        }
        task.resume()
    }
}
