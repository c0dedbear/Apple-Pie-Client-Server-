//
//  UserController.swift
//  App
//
//  Created by Михаил Медведев on 03/08/2019.
//

import Vapor
import Crypto
import FluentMySQL
import Authentication

final class UserController {
    
    //MARK: - Create
    func renderCreatePage(_ req: Request) throws -> Future<View> {
        let context = HomePageViewContext(username: nil, email: nil, date: nil, showHidingBlock: "true")
        return try req.view().render("users-create", context)
    }
    
    func createUser(_ req: Request) throws -> Future<View> {
        //check if user has Authenticated session
        guard let _ = try req.authenticatedSession(User.self) else {
            print(#line, #function,"🔴 Not Authenticated session detected! Render Login page...")
            return try renderLoginPage(req)}
        return try req.content.decode(User.self).flatMap(to: View.self) { user in
            return User.query(on: req).filter(\.email == user.email).filter(\.username == user.username).first()
                .flatMap(to: View.self) { alreadyExistingUser in
                    if alreadyExistingUser == nil {
                        let encrytedUser = User(id: nil, username: user.username, password: try BCrypt.hash(user.password), email: user.email, createdAt: Date())
                        return encrytedUser.save(on: req).flatMap(to: View.self) { user in
                            let userCreatedContext = HomePageViewContext(username: user.username, email: nil, date: nil, showHidingBlock: nil)
                            return try req.view().render("user-create-success", userCreatedContext)
                        }
                    } else {
                        print("🔺 Create user error")
                        let context = ErrorContext(); return try req.view().render("users-create", context)
                    }
                }.catchFlatMap(){ error in
                    //handle error caused by MySQL Error (for example not unique value in database)
                    try self.handleMySQLError(error, req, user)
            }
        }
    }
    
    //supporting func for createUser
    func handleMySQLError(_ error: Error, _ req: Request, _ user: User) throws -> Future<View> {
        print(#line, #function, error.localizedDescription)
        let emailError = RegistrationErrorContext(emailDuplicate: "true", userEmail: user.email, userNameDuplicate: nil, userName: user.username, showHidingBlock: "true")
        let usernameError = RegistrationErrorContext(emailDuplicate: nil, userEmail:  user.email, userNameDuplicate: "true", userName: user.username, showHidingBlock: "true")
        let errorContext = error.localizedDescription.contains("'email'") ? emailError : usernameError
        
        return try req.view().render("users-create", errorContext)
    }
    
    
    //MARK: - Login
    func renderLoginPage(_ req: Request) throws -> Future<View> {
        return try req.view().render("users-login")
    }
    
    func login(_ req: Request) throws -> Future<Response> {
        return try req.content.decode(User.self).flatMap(){ user in
            return User.authenticate(
                username: user.username,
                password: user.password,
                using: BCryptDigest(),
                on: req)
            }.flatMap(){ user in
                guard let authUser = user else {
                    //Render View to show login error in leaf page
                    let context = ErrorContext()
                    return try req.view().render("users-login", context).encode(for: req)
                }
                try req.authenticateSession(authUser)
                return try req.redirect(to: WebRoutesPaths.main.rawValue).encode(for: req)
                // return try self.homePageController.renderHomePage(req)
        }
    }
    
    //MARK: - Logout
    func logout(_ req: Request) throws -> Future<Response> {
        try req.unauthenticateSession(User.self)
        return Future.map(on: req) { return req.redirect(to: WebRoutesPaths.main.rawValue) }
    }
    
    //MARK: -  List
    func renderUsersList(_ req: Request) throws -> Future<View> {
        return User.query(on: req).all().flatMap(to: View.self) { users in
            let context = UsersListContext(users: users, showHidingBlock: "true")
            return try req.view().render("users", context)
        }
    }
    
    //MARK: - Delete
    func delete(_ req: Request) throws -> Future<Response> {
        //check if user has Authenticated session
        guard let _ = try req.authenticatedSession(User.self) else {
            print(#line, #function,"🔴 Not Authenticated session detected! Redirect to Login page...")
            return try req.redirect(to: WebRoutesPaths.login.rawValue).encode(for: req)
            
        }
        return try req.parameters.next(User.self).flatMap { user in
            return user.delete(on: req).map { _ in
                print(#line, #function, "🔻 User @\(user.username)(id:\(user.id ?? 0)) was deleted from DataBase!")
                return req.redirect(to: WebRoutesPaths.users.rawValue)
            }
        }
    }
    
    //MARK: - Update
    func update(_ req: Request) throws -> Future<Response> {
        //check if user has Authenticated session
        guard let _ = try req.authenticatedSession(User.self) else {
            print(#line, #function,"🔴 Not Authenticated session detected! Redirect to Login page...")
            return try req.redirect(to: WebRoutesPaths.login.rawValue).encode(for: req)
            
        }
        
        return try req.parameters.next(User.self).flatMap { user in
            return try req.content.decode(User.UserUpdateForm.self).flatMap(){ usersChangedValues in
                var updatedUser = user
                updatedUser.username = usersChangedValues.username
                updatedUser.email = usersChangedValues.email
                if updatedUser != user {
                    return updatedUser.save(on: req).map() { _ in
                        print(#line, #function, "🔶 User with (id:\(user.id ?? 0)) was updated in DataBase!")
                        return req.redirect(to: WebRoutesPaths.users.rawValue)
                    }
                } else {
                    print(#line, #function, "🔶 Nothing to update!")
                    return try req.redirect(to: WebRoutesPaths.users.rawValue).encode(for: req)
                }
            }
        }
    }
    
}

