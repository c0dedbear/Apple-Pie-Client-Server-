//
//  MainViewController.swift
//  Apple Pie
//
//  Created by Denis Bystruev on 29/03/2018.
//  Copyright © 2018 Denis Bystruev. All rights reserved.
//
// Modified by Mikhail Medvedev in 2019.

import UIKit

class MainViewController: UIViewController {
    
    //MARK: Dependencies
    let networkController = NetworkController()
    
    //MARK: Game Properties
    
    let incorrectMovesAllowed = 7
    
    var currentGame: Game!
    var listOfWords = [String]()
    
    var totalWins = 0 {
        didSet {
            newRound(after: 0.5)
        }
    }
    
    var totalLoses = 0 {
        didSet {
            currentGame.formattedWord = currentGame.word
            newRound(after: 0.5)
        }
    }
    
    var currentCategory: Category! {
        didSet {
            if currentCategory.words != nil {
                currentCategoryLabel.text = currentCategory.name
                listOfWords = currentCategory.words!.map {$0.value}
                newRound()
            } else {
                listOfWords = Word.offlineWords
                newRound()
            }
        }
    }
    
    var keysEnabled = false
    
    //MARK: @IBOutlets
    @IBOutlet weak var treeImageView: UIImageView!
    @IBOutlet weak var correctWordLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var currentCategoryLabel: UILabel!
    
    //MARK: @IBActions
    @IBAction func buttonTapped(_ sender: UIButton) {
        sender.isEnabled = false
        let letterString = sender.title(for: .normal)!
        let letter = Character(letterString.lowercased())
        currentGame.playerGuessed(letter: letter)
        updateGameState()
    }
    
    //MARK: ViewController Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCategoryWithWords()
    }
    
    
    //MARK: Methods
    func enableButtons(_ enable: Bool, in view: UIView) {
        keysEnabled = enable
        if view is UIButton {
            (view as! UIButton).isEnabled  = enable
        } else {
            for subview in view.subviews {
                if subview != settingsButton {
                    enableButtons(enable, in: subview)
                }
            }
        }
    }
    
    func newRound() {

        if !listOfWords.isEmpty {
            let randomIndex = Int(arc4random_uniform(UInt32(listOfWords.count)))
            let newWord = listOfWords.remove(at: randomIndex)
            currentGame = Game(
                word: newWord.lowercased(),
                incorrectMovesRemaining: incorrectMovesAllowed,
                guessedLetters: []
            )
            enableButtons(true, in: view)
            updateUI()
        } else {
            enableButtons(false, in: view)
            //select new category if game ends
            if !keysEnabled {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            print(#line, #function, Date())
                    self.performSegue(withIdentifier: "settingsSegue", sender: nil)
                }
            }
        }
    }
    
    func newRound(after delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.newRound()
        }
    }
    
    func updateGameState() {
        if currentGame.incorrectMovesRemaining < 1 {
            totalLoses += 1
        } else if currentGame.word == currentGame.formattedWord {
            totalWins += 1
        }
        updateUI()
    }
    
    func updateUI() {
        var letters = [String]()
        for letter in currentGame.formattedWord {
            letters.append(String(letter))
        }
        letters[0] = letters[0].capitalized
        let wordWithSpacing = letters.joined(separator: " ")
        correctWordLabel.text = wordWithSpacing
        scoreLabel.text = "Выиграно: \(totalWins), Проиграно: \(totalLoses)"
        treeImageView.image = UIImage(named: "Tree \(currentGame.incorrectMovesRemaining)")
    }
    
}

// MARK: - Navigation
extension MainViewController {
    @IBAction func unwind(_ segue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsSegue" {
            let settingsViewController = segue.destination as! SettingsViewController
            settingsViewController.currentCategory = currentCategory
        }
    }
}


// MARK: - Networking
extension MainViewController {
    func fetchCategoryWithWords() {
        
        networkController.fetchCategories { categories in
            guard let categories = categories else {
                self.currentCategory = Category(id: 0, name: "Разработка", words: nil)
                self.currentCategoryLabel.text = self.currentCategory?.name
                self.listOfWords = Word.offlineWords
                self.newRound()
                return
            }
            
            // set current category randomly
            let randomCategoryIndex = Int.random(in: 0...categories.count - 1)
            self.currentCategory = categories[randomCategoryIndex]
            
            self.networkController.fetchWords(for: self.currentCategory!) { words in
                self.currentCategory?.words = words
                self.listOfWords = self.currentCategory!.words!.map {$0.value}
                DispatchQueue.main.async {
                    self.currentCategoryLabel.text = self.currentCategory?.name
                    self.newRound()
                }
            }
        }
    }
}
