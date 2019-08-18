//
//  Game.swift
//  Apple Pie
//
//  Created by Denis Bystruev on 29/03/2018.
//  Copyright © 2018 Denis Bystruev. All rights reserved.
//

import Foundation

struct Game {
    var word: String
    var incorrectMovesRemaining: Int
    var guessedLetters: [Character]
    
    var formattedWord: String {
        get {
            var guessedWord = ""
            for letter in word {
                if guessedLetters.contains(letter) {
                    guessedWord += "\(letter)"
                } else {
                    guessedWord += "_"
                }
            }
            return guessedWord
        }
        set {
            for letter in newValue {
                playerGuessed(letter: letter)
            }
        }
    }
    
    mutating func playerGuessed(letter: Character) {
        guessedLetters.append(letter)
        if !word.contains(letter) {
            incorrectMovesRemaining -= 1
        }
    }
}
