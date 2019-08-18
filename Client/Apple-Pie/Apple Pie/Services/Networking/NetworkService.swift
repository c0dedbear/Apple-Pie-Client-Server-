//
//  NetworkService.swift
//  
//
//  Created by Михаил Медведев on 26/07/2019.
//  Copyright © 2019 Denis Bystruev. All rights reserved.
//

import Foundation

enum RequestType: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
    case update = "UPDATE"
}

class NetworkService: NetworkRequestable {
    
    /// Creates Data Task with request
    ///
    /// - Parameters:
    ///   - request: URLRequest
    ///   - completion: (Data?, Error?) -> Void
    /// - Returns: URLSessionDataTask
    private func createDataTask(with request: URLRequest, completion: @escaping (Data?, Error?) -> Void) -> URLSessionDataTask {
        return URLSession.shared.dataTask(with: request, completionHandler: { data, _, error in
            DispatchQueue.main.async {
                completion(data, error)
            }
        })
    }
    
    /// Make request to specified URL
    ///
    /// - Parameters:
    ///   - data: Data?
    ///   - url: URL?
    ///   - type: RequestType
    ///   - response: (Data?, Error?) -> Void
    func request(to url: URL?, type: RequestType, with data: Data?, response: @escaping (Data?, Error?) -> Void) {
        guard let url = url else {
            print(#line, #function, "URL is not valid")
            return
        }
        
        var request = URLRequest(url: url)
        
        switch type {
        case .get: request.httpMethod = RequestType.get.rawValue
        case .post: request.httpMethod = RequestType.post.rawValue
        case .put: request.httpMethod = RequestType.put.rawValue
        case .delete: request.httpMethod = RequestType.delete.rawValue
        case .update: request.httpMethod = RequestType.update.rawValue
        }
        
        if let data = data {
            request.httpBody = data
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let task = createDataTask(with: request, completion: response)
        task.resume()
    }
    
}
