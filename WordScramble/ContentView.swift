//
//  ContentView.swift
//  WordScramble
//
//  Created by Enzo Ficoseco on 26/07/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var userScore = 0
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
                Section {
                    Text("Score: \(userScore)")
                }
            }
            .navigationTitle(rootWord)
            .toolbar {
                ToolbarItem( placement: .navigationBarTrailing) {
                    Button(action: {
                        startGame()
                        usedWords = []
                        userScore = 0
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) { } message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord() {
        
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You cannot spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isLargeEnough(word: answer) else {
            wordError(title: "Word is too short", message: "You must write a word that is larger than 2 letters!")
            return
        }
        
        guard sameWord(word: answer) else {
            wordError(title: "Same word", message: "You cannot use the same word! Think again")
            return
        }
        
        withAnimation{
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
        
        userScore += answer.count
        
    }

    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func isLargeEnough(word: String) -> Bool {
        if word.count >= 3 {
            return true
        } else {
            return false
        }
    }
    
    func sameWord(word: String) -> Bool {
        if word == rootWord {
            return false
        } else {
            return true
        }
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}
