//
//  CategoryController.swift
//  App
//
//  Created by Михаил Медведев on 04/08/2019.
//

import Vapor
import FluentMySQL
import Authentication

final class CategoryController {
    
    /// Renders Leaf
    ///
    /// - Parameter req: Request
    /// - Returns: View(categories.leaf)
    /// - Throws: Error
    func renderCategoryList(_ req: Request) throws -> Future<View> {
        
        let allCategories = Category.query(on: req).all()
        return allCategories.flatMap(){ categories in
            
            let categoryViewList = try categories.map { category in
                return CategoriesView(category: category,
                                    words: try category.words.query(on: req).all()
                )
                
            }
            let data = ["categoryViewList": categoryViewList] 
            
            return try req.view().render("categories", data)
        }
    }
    
    func renderCategoryWords(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Category.self).flatMap { category in
            return Word.query(on: req).filter(\.categoryId == category.id!).all().flatMap(to: View.self) { words in
                let context = CategoryWordsContext(category: category, words: words, error: false)
                return try req.view().render("category", context)
            }
        }
    }
    
    /// Creates category
    ///
    /// - Parameter req: Request
    /// - Returns: <Response> (redirect to WebRoutesPaths.categories if success created)
    /// - Throws: Abort
    func create(_ req: Request) throws -> Future<Response> {
        
        //get authenticated user for creating category
        let user = try req.requireAuthenticated(User.self)
        
        return try req.content.decode(Category.self).flatMap() { category in
            return Category.query(on: req).filter(\.name == category.name).first()
                .flatMap(){ alreadyExistingCategory in
                    if alreadyExistingCategory == nil {
                        let categoryToAdd = Category(id: nil, name: category.name, user: user.username, date: Date())
                        return categoryToAdd.save(on: req).map() { _ in
                            return req.redirect(to: WebRoutesPaths.categories.rawValue)
                        }
                    } else {
                        print("abort")
                        throw Abort(.notFound, reason: "Такая категория уже существует")
                    }
            }
        }
    }
    

    func update(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(Category.self).flatMap { category in
            return try req.content.decode(Category.CategoryUpdate.self).flatMap(){ categoryChangedValue in
                var updatedCategory = category
                updatedCategory.name = categoryChangedValue.name
                if updatedCategory.name != category.name {
                    return updatedCategory.save(on: req).map() { _ in
                        print(#line, #function, "🔶 Category with (id:\(category.id ?? 0)) was updated in DataBase on \(Date())!")
                        return req.redirect(to: WebRoutesPaths.categories.rawValue)
                    }
                } else {
                    print(#line, #function, "🔶 Nothing to update!")
                    return try req.redirect(to: WebRoutesPaths.categories.rawValue).encode(for: req)
                }
            }
        }
    }
    
    /// Deletes category with all related words
    ///
    /// - Parameter req: Request
    /// - Returns: <Response> (redirect to WebRoutesPaths.categories)
    /// - Throws: Error
    func delete(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(Category.self).flatMap { category in
            return try category.words.query(on: req).delete().flatMap { _ in
                return category.delete(on: req).map { _ in
                    return req.redirect(to: WebRoutesPaths.categories.rawValue)
                }
            }
        }
    }
    
}

