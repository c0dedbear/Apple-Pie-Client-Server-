//
//  NetworkController.swift
//  
//
//  Created by Михаил Медведев on 26/07/2019.
//  Copyright © 2019 Denis Bystruev. All rights reserved.
//

import Foundation

class NetworkController {
    
    let jsonDataFetcher: JSONDataFetchable
    let jsonDataSender: JSONDataSendable
    
    let baseURL = URL(string: "http://localhost:8080/api")
    
    init(jsonDataFetcher: JSONDataFetchable = JSONDataFetcher(),jsonDataSender: JSONDataSendable = JSONDataSender()) {
        self.jsonDataFetcher = jsonDataFetcher
        self.jsonDataSender = jsonDataSender
    }
    
    func fetchCategories(completion: @escaping ([Category]?) -> Void) {
        guard let url = baseURL?.appendingPathComponent("categories") else { return }
        jsonDataFetcher.fetchJSONData(url: url, response: completion)
    }
    
    func fetchWords(for category: Category, completion: @escaping ([Word]?) -> Void) {
        guard let url = baseURL?.appendingPathComponent("category").appendingPathComponent("\(category.id)/words") else { return }
        jsonDataFetcher.fetchJSONData(url: url, response: completion)
    }
    
}
