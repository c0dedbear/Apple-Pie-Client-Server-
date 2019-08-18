//
//  LeafContexts.swift
//  App
//
//  Created by Михаил Медведев on 11/08/2019.
//

import Foundation
import Vapor

struct HomePageViewContext: Codable {
    var username: String?
    var email: String?
    var date: Date?
    var showHidingBlock: String?
    
}

struct RegistrationErrorContext: Codable {
    var emailDuplicate: String?
    var userEmail: String?
    var userNameDuplicate: String?
    var userName: String?
    var showHidingBlock: String?
}

struct UsersListContext: Codable {
    var users: [User]
    var showHidingBlock: String?
}

struct ErrorContext: Codable {
    let error = "true"
}

struct CategoryWordsContext: Codable {
    var category: Category
    var words: [Word]
    let error: Bool
}

struct CategoriesView: Encodable {
    var category: Category
    var words: Future<[Word]>
}
