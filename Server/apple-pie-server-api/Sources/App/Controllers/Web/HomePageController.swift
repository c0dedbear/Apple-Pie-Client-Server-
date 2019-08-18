//
//  HomePageController.swift
//  App
//
//  Created by Михаил Медведев on 11/08/2019.
//

import Vapor

final class HomePageController {
    
    func renderHomePage(_ req: Request) throws -> Future<View> {
        let user = try req.requireAuthenticated(User.self)
        let context = HomePageViewContext(username: user.username, email: nil, date: Date(), showHidingBlock: "true")
        return try req.view().render("main", context)
        
    }
}
