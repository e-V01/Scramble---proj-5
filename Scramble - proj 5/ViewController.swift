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
        cell.textLabel?.text = usedWords[indexPath.row] // all words user found so far and show they found these words
        return cell
    }
}

