//
//  ViewController.swift
//  Scramble - proj 5
//
//  Created by Y K on 17.07.2023.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()
    
    func showErrorMessage(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)   // refactored else block with new method
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Start Game", style: .plain, target: self, action: #selector(startGame)) // aded leftBarButtonItem to start new game
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer)) //  closures are treated as var
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        startGame()
    }
    
    
    @objc func startGame() {
        title = allWords.randomElement() // set view controller inside it in random
        usedWords.removeAll(keepingCapacity: true) // removes all values from used words
        tableView.reloadData() // reload all rows and sections from scratch
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        // all words user found so far and show the found words
        return cell
    }
    
    @objc func promptForAnswer() { // new method
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField() // adds field to type in
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { // closure
            [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            // ? added to optionally unwrap check whether there is value in ac and textfield
            self?.submit(answer)
            
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) { //modified else blocks
        let lowerAnswer = answer.lowercased()

        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if let errorMessage = isReal(word: lowerAnswer) {
                    showErrorMessage(title: "Word not recognized", message: errorMessage)
                } else {
                    usedWords.insert(answer, at: 0)
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                }
            } else {
                showErrorMessage(title: "Word already used", message: "Be more original")
            }
        } else {
            guard let title = title else { return }
            showErrorMessage(title: "Word doesn't exist", message: "You cannot spell that word from \(title.lowercased())")
        }
    }

    
    
    
    func isPossible(word: String) -> Bool {
        
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    
    func isReal(word: String) -> String? { // substituted bool with string(optional) to return message
        
        if word.count < 3 || word == title?.lowercased() {
            return "Word has to be longer than 3 characters"
        }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        // we care about in, range and language;  startingAT and wrap parameter aren`t imporatnt
        return ((misspelledRange.location == NSNotFound ? nil : "Word not recognized"))
        // shows us where the misspelling was found,  no way to nil it
        
    }
}
