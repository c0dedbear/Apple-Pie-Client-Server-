//
//  User.swift
//  App
//
//  Created by Михаил Медведев on 04/08/2019.
//

import Vapor
import FluentMySQL
import Authentication
//import FluentPostgreSQL

struct User: Content, MySQLModel, Migration {
    var id: Int?
    var username: String
    var password: String
    var email: String?
    var createdAt: Date?
    
    struct UserLoginForm: Content {
        var username: String
        var password: String
    }
    
    struct UserUpdateForm: Content {
        var username: String
        var email: String
    }
    
}

extension User: Comparable {
    static func < (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id && lhs.username == rhs.username && lhs.password == rhs.password && lhs.email == rhs.email && lhs.createdAt == rhs.createdAt
    }
    
    
}
extension User: Parameter {}
extension User: SessionAuthenticatable {}

extension User: PasswordAuthenticatable {
    static var usernameKey: WritableKeyPath<User, String> {
        return \User.username
    }
    static var passwordKey: WritableKeyPath<User, String> {
        return \User.password
    }
}

