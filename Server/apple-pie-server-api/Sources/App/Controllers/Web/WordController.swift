//
//  WordController.swift
//  App
//
//  Created by Михаил Медведев on 14/08/2019.
//

import Vapor
import FluentMySQL

final class WordController {
    
    func create(_ req: Request) throws -> Future<Response> {
        //get current authenticated user
        let user = try req.requireAuthenticated(User.self)
        
        return try req.content.decode(Word.Crud.self)
            .flatMap(){ newWord in
                return Word.query(on: req)
                    .filter(\.categoryId == newWord.categoryId)
                    .filter(\.value == newWord.value).first()
                    .flatMap(){ existingWord in
                        let path = WebRoutesPaths.category.rawValue + "/" + String(newWord.categoryId)
                        
                        if existingWord == nil {
                            let word = Word(id: nil, categoryId: newWord.categoryId, value: newWord.value, user: user.username, date: Date())
                            return word.save(on: req).map() { word in
                                return req.redirect(to: path)
                            }
                        } else {
                            return try req.parameters.next(Category.self).flatMap { category in
                                return Word.query(on: req)
                                    .filter(\.categoryId == category.id!)
                                    .all()
                                    .flatMap(){ words in
                                        let context = CategoryWordsContext(category: category, words: words, error: true)
                                        return try req.view().render("category", context).encode(for: req)
                                }
                            }
                        }
                }
        }
        
    }
    
    func update(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(Word.self).flatMap { word in
            //decode form
            return try req.content.decode(Word.Crud.self).flatMap(){ updatedWord in
                //redirect path
                let path = WebRoutesPaths.category.rawValue + "/" + String(updatedWord.categoryId)
                //check if word in form was really updated if not just update page
                guard updatedWord.value != word.value else { return try req.redirect(to: path).encode(for: req) }
                //search for word in category
                    return Category.query(on: req).filter(\.id == word.categoryId).first().flatMap(){ category in
                        guard let existingCategory = category else { throw Abort(.notFound, reason: "Category doesn't exist") }
                        return try existingCategory.words.query(on: req)
                            .filter(\.value == updatedWord.value)
                            .first()
                            .flatMap(){ findedWord in
                                //word is not duplicated
                                if findedWord == nil {
                                  var changedWord = word
                                   changedWord.value = updatedWord.value
                                    return changedWord.save(on: req).map() { _ in
                                        print(#line, #function,
                                              "🔶 Word '\(word.value)' was changed to '\(changedWord.value)' in DataBase on \(Date())!"
                                        )
                                        return req.redirect(to: path)
                                    }
                                } else {
                                    //words value is duplicate
                                    print(#line, #function, "🔶 \(updatedWord.value) already exits in this category")
                                    return try req.redirect(to: path).encode(for: req)
                                }
                        }
                    }
                
            }
        }
    }
    
    /// Deletes word from category
    ///
    /// - Parameter req: Request
    /// - Returns: <Response> (redirect to WebRoutesPaths.category + "/" + <id>)
    /// - Throws: Error
    func delete(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(Word.self).flatMap { word in
            return word.delete(on: req).map() { _ in
                let path = WebRoutesPaths.category.rawValue + "/" + String(word.categoryId)
                print(#line, #function, "🔻 Word \"\(word.value)\" was deleted in DataBase on \(Date())!")
                return req.redirect(to: path)
            }
        }
    }
    
}



