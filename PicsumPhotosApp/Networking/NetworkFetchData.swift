//
//  NetworkFetchData.swift
//  PicsumPhotosApp
//
//  Created by Артем Ропавка on 14.11.2021.
//

import Foundation

protocol FetchData {
    func fetchGenericJSONData<T: Decodable>(urlString: String, response: @escaping (T?) -> Void)
}

class NetworkFetchData: FetchData {
    
    var networking: Networking
    private var jsonResponse: Any?
    
    init(networking: Networking = NetworkService()) {
        self.networking = networking
    }
    
    func searchImages(searchTerm: String, completion: @escaping (SearchResult?) -> ()) {
        fetchGenericJSONData(urlString: searchTerm, response: completion)
    }
    
    func fetchGenericJSONData<T: Decodable>(urlString: String, response: @escaping (T?) -> Void) {
        print(T.self)
        networking.searchRequest(searchTerm: urlString) { (data, error) in
            if let error = error {
                print("Error received requesting data: \(error.localizedDescription)")
                response(nil)
            }
            
            let decoded = self.decodeJSON(type: T.self, from: data)
            response(decoded)
            
        }
    }
    
    func decodeJSON<T: Decodable>(type: T.Type, from: Data?) -> T? {
        let decoder = JSONDecoder()
        guard let data = from else { return nil }
        do {
            
            jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.init(rawValue: 0))
            guard let jsonResponse = jsonResponse as? [String: Any],
                let results = jsonResponse["results"] as? [Any] else {
                    return nil
            }
            print(results)
            
            let objects = try decoder.decode(type.self, from: data)
    
            print(objects)
            return objects
        } catch let jsonError {
            print("Failed to decode JSON", jsonError)
            return nil
        }
    }
}








