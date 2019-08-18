//
//  Word.swift
//  Apple Pie
//
//  Created by Михаил Медведев on 26/07/2019.
//  Copyright © 2019 Denis Bystruev. All rights reserved.
//

import Foundation

struct Word: Codable {
    
    var id: UUID?
    var value: String
    
    static let offlineWords = ["Приложение", "Клиент", "Сервер"]

}
