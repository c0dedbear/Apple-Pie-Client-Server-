//
//  Word.swift
//  App
//
//  Created by Михаил Медведев on 29/07/2019.
//

import Vapor
import FluentMySQL
//import FluentPostgreSQL
//import FluentSQLite


struct Word: Content, MySQLUUIDModel, Migration {
    var id: UUID?
    var categoryId: Int
    var value: String
    var user: String
    var date: Date
    
    struct Crud: Decodable {
        let value: String
        let categoryId: Int
    }
}

extension Word: Parameter {}

// MARK: - Relation to Category
extension Word {
    var category: Parent<Word,Category> {
        return parent(\.categoryId)
    }
}

