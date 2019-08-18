//
//  JSONDataFetcher.swift
//
//
//  Created by Михаил Медведев on 26/07/2019.
//  Copyright © 2019 Denis Bystruev. All rights reserved.
//

import Foundation

class JSONDataSender: JSONDataSendable {
    
    private let networkService: NetworkRequestable
    
    // can be initializated with other classes in future (depending of request types)
    init(networkService: NetworkRequestable = NetworkService()) {
        self.networkService = networkService
    }
    
    /// Returns encoded data from Generic Type
    ///
    /// - Parameters:
    ///   - type: T
    /// - Returns: Data?
    func encodeJSONData<T: Codable>(of type: T) -> Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(type)
    }
    
    
    /// Send JSON Data to Server
    ///
    /// - Parameters:
    ///   - url: URL
    ///   - requestType: RequestType
    ///   - model: T (generic)
    ///   - response: [String: Any]?) -> Void)
    func sendJSONData<T: Codable>(url: URL, with requestType: RequestType, using model: T, response: @escaping ([String: Any]?, Error?) -> Void) {
        guard let data = encodeJSONData(of: model) else {
            print(#file, #line, #function, "Failed to encode Model to Data")
            response(nil, nil)
            return
        }
        //send request
        networkService.request(to: url, type: requestType, with: data){ data, error in
            //catch error
            if let error = error {
                response(nil, error)
                return
            }
            //fetch response data
            if let fetchedData = data {
                let decodedData = try? JSONSerialization.jsonObject(with: fetchedData, options: []) as? [String : Any]
                response(decodedData, nil)
            }
            
        }
    }
    
}
