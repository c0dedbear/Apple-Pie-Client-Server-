//
//  APICategoryController.swift
//  App
//
//  Created by Михаил Медведев on 17/08/2019.
//

import Vapor
import FluentMySQL

final class APIController {
    
    func getCategories(_ req: Request) throws -> Future<[Category]> {
        return Category.query(on: req).all()
    }
    
    func getWordsFromCategory(_ req: Request) throws -> Future<[Word]> {
        return try req.parameters.next(Category.self).flatMap(){ category in
            return try category.words.query(on: req).all()
        }
    }
    
}
