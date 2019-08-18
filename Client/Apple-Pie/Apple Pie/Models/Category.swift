//
//  Category.swift
//  Apple Pie
//
//  Created by Михаил Медведев on 02/08/2019.
//  Copyright © 2019 Denis Bystruev. All rights reserved.
//

import Foundation

struct Category: Codable {
    var id: Int
    var name: String
    var words: [Word]?
}
