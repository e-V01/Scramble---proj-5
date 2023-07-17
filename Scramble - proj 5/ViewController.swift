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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    
    func startGame() {
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
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased() // lowercase, avoid problem with uppercase
        
        let errorTitle: String
        let errorMessage: String
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                usedWords.insert(answer, at: 0) // at the top of tableView
                
                let indexPath = IndexPath(row: 0, section: 0)
                tableView.insertRows(at: [indexPath], with: .automatic) // slide new row in from the top
                
                return
            } else {
                errorTitle = "Word not recogniced"
                errorMessage = "You cannot just make it up"
            }
        } else {
            errorTitle = "Word already used"
            errorMessage = "Be more original"
        }
    } else {
        guard let title = title else { return } // in case we do not have title or don not want o force unwrap it
        errorTitle = "Word doesn`t exist"
        errorMessage = "You cannot spell that word from \(title.lowercased())"
    }
    
    let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default))
    present(ac,animated: true)
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
    
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "EN")
        // we care about in, range and language;  startingAT and wrap parameter aren`t imporatnt
        return misspelledRange.location == NSNotFound
        // shows us where the misspelling was found,  no way to nil it
        
    }
}
