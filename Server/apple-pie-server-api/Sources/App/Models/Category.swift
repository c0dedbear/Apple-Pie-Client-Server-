//
//  Category.swift
//  App
//
//  Created by Михаил Медведев on 02/08/2019.
//

import Vapor
//import FluentPostgreSQL
import FluentMySQL
//import FluentSQLite

struct Category: Content, MySQLModel, Migration {
    var id: Int?
    var name: String
    var user: String?
    var date: Date?
    
    struct CategoryUpdate: Decodable {
         var name: String
    }
    
    struct APICategory: Encodable {
        var name: String
        var words: [Word]?
    }
}

extension Category: Parameter {}

// MARK: - Relation to Word
extension Category {
    var words: Children<Category,Word> {
        return children(\.categoryId)
    }
}
