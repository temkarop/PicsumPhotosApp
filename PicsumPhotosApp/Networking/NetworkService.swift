//
//  NetworkService.swift
//  PicsumPhotosApp
//
//  Created by Артем Ропавка on 14.11.2021.
//

import Foundation

protocol Networking {
    func searchRequest(searchTerm: String, completion: @escaping (Data?, Error?) -> Void)
}

class NetworkService: Networking {

    var timeoutInterval = 30.0

    func searchRequest(searchTerm: String, completion: @escaping (Data?, Error?) -> Void) {

        let parameters = prepareParameters(searchTerm: searchTerm)
        let url = URL(string: "https://api.unsplash.com/search/photos")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.query = queryParameters(parameters)
        
        var request = URLRequest(url: components.url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeoutInterval)
        
        request.allHTTPHeaderFields = prepareHeaders()
        print(request.allHTTPHeaderFields!)
        request.httpMethod = "get"
        
        
        let task = createDataTask(from: request, completion: completion)
        task.resume()
    }
    
    func prepareHeaders() -> [String: String]? {
        var headers = [String: String]()
        headers["Authorization"] = "Client-ID Vaj2LAfrnWOt_2eSrrHu9nuJzGFq6syIX_D81rqmTZo"
        return headers
    }
    
    func prepareParameters(searchTerm: String?) -> [String: Any]? {
        var parameters = [String: Any]()
        parameters["query"] = searchTerm
        parameters["page"] = 1
        parameters["per_page"] = 10
        return parameters
    }
    
    private func queryParameters(_ parameters: [String: Any]?, urlEncoded: Bool = false) -> String {
        var allowedCharacterSet = CharacterSet.alphanumerics
        allowedCharacterSet.insert(charactersIn: ".-_")
        
        var query = ""
        parameters?.forEach { key, value in
            let encodedValue: String
            if let value = value as? String {
                encodedValue = urlEncoded ? value.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? "" : value
            } else {
                encodedValue = "\(value)"
            }
            query = "\(query)\(key)=\(encodedValue)&"
        }
        
        print(#function, query)
        return query
    }
    
    private func createDataTask(from requst: URLRequest, completion: @escaping (Data?, Error?) -> Void) -> URLSessionDataTask {
        return URLSession.shared.dataTask(with: requst, completionHandler: { (data, response, error) in
            DispatchQueue.main.async {
                completion(data, error)
                print(response!)
            }
        })
    }
}
    
