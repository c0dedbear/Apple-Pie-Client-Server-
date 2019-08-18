//
//  SampleDataLoader.swift
//  App
//
//
//  Created by Михаил Медведев on 16/08/2019.
//

import Vapor
import FluentMySQL
import Crypto

import Foundation

//using this only for first launch to setup database sample data
final class SampleDataLoader {

    func load(_ req: Request) throws -> Future<View> {
        
        let categories = [
            Category(id: 1, name: "Фрукты", user: "admin", date: Date()),
            Category(id: 2, name: "Овощи", user: "admin", date: Date()),
            Category(id: 3, name: "Города", user: "admin", date: Date()),
            Category(id: 4, name: "Страны", user: "admin", date: Date()),
            Category(id: 5, name: "Фильмы", user: "admin", date: Date()),
            Category(id: 6, name: "Спорт", user: "admin", date: Date()),
        ]
        
        let words = [
        Word(id: nil, categoryId: 1, value: "Киви", user: "admin", date: Date()),
        Word(id: nil, categoryId: 1, value: "Груша", user: "admin", date: Date()),
        Word(id: nil, categoryId: 1, value: "Банан", user: "admin", date: Date()),
        Word(id: nil, categoryId: 2, value: "Лук", user: "admin", date: Date()),
        Word(id: nil, categoryId: 2, value: "Картофель", user: "admin", date: Date()),
        Word(id: nil, categoryId: 3, value: "Москва", user: "admin", date: Date()),
        Word(id: nil, categoryId: 3, value: "Сочи", user: "admin", date: Date()),
        Word(id: nil, categoryId: 3, value: "Лондон", user: "admin", date: Date()),
        Word(id: nil, categoryId: 3, value: "Владивосток", user: "admin", date: Date()),
        Word(id: nil, categoryId: 4, value: "Италия", user: "admin", date: Date()),
        Word(id: nil, categoryId: 4, value: "Грузия", user: "admin", date: Date()),
        Word(id: nil, categoryId: 4, value: "Турция", user: "admin", date: Date()),
        Word(id: nil, categoryId: 4, value: "Россия", user: "admin", date: Date()),
        Word(id: nil, categoryId: 4, value: "Германия", user: "admin", date: Date()),
        Word(id: nil, categoryId: 4, value: "Испания", user: "admin", date: Date()),
        Word(id: nil, categoryId: 5, value: "Оно", user: "admin", date: Date()),
        Word(id: nil, categoryId: 5, value: "Афоня", user: "admin", date: Date()),
        Word(id: nil, categoryId: 5, value: "Интерстеллар", user: "admin", date: Date()),
        Word(id: nil, categoryId: 6, value: "Футбол", user: "admin", date: Date()),
        Word(id: nil, categoryId: 6, value: "Хоккей", user: "admin", date: Date()),
        Word(id: nil, categoryId: 6, value: "Теннис", user: "admin", date: Date()),
        Word(id: nil, categoryId: 6, value: "Лапта", user: "admin", date: Date()),
        ]
            
        let users = [
                User(id: 1, username: "admin", password: try BCrypt.hash("admin"), email: "admin@admindomain.com", createdAt: Date()),
                User(id: 2, username: "test1", password: try BCrypt.hash("admin"), email: "test1@testdomain.ru", createdAt: Date()),
                User(id: 3, username: "test2", password: try BCrypt.hash("admin"), email: "test3@testdomain.ru", createdAt: Date()),
                User(id: 4, username: "test3", password: try BCrypt.hash("admin"), email: "test4@testdomain.ru", createdAt: Date()),
                User(id: 5, username: "test4", password: try BCrypt.hash("admin"), email: "test5@testdomain.ru", createdAt: Date()),
                User(id: 6, username: "test5", password: try BCrypt.hash("admin"), email: "test6@testdomain.ru", createdAt: Date()),
            ]
            
        
        return try req.view().render("setup-ok").always {
            users.forEach { _ = $0.create(on: req)}
            categories.forEach { _ = $0.create(on: req)}
            words.forEach { _ = $0.create(on: req)}
        }
        
    }
}
    

