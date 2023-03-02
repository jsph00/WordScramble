//
//  ContentView.swift
//  WordScrambleV2
//
//  Created by Joe Yi on 11/30/22.
//
//  -Disallow answers that are shorter than three letters
//  -Add a toolbar that calls startGame() which allows users to restart with a new word
//  -Create a text view to track player's score
//
//  -added accessibility with VoiceOver
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showError = false
    
    @State private var score = 0            //adding score tracking feature
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                        .accessibilityElement(children: .ignore) //children: ignore is default
                        .accessibilityLabel("\(word), \(word.count) letters")
                        //below is word, then letter count
                        //.accessibilityLabel(word)
                        //.accessibilityHint("\(word.count) letters")
                        
                    }
                }
                
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented:$showError) {
                Button("OK", role: .cancel) { }
            }message: {
                Text(errorMessage)
            }
            .toolbar {                                  //inserts button to start new game
                Button("New Game", action: startGame)
            }
            .safeAreaInset(edge: .bottom) {             //added score feature
                Text("Score: \(score)")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .font(.title)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 3 else { wordError(title: "Word too short", message: "Words must be four characters or more.")
            return
        }       //answer must have more than 3 characters
        guard answer != rootWord else { wordError(title: "Nice try..", message: "You can't use the starting word.")
            return
        }       //answer cannot be root word

        guard isOriginal(word: answer) else {
            wordError(title: "Word used alread", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from \(rootWord)!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't make up words.")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
        score += answer.count   //score determined by length of word
    }
    
    func startGame() {
        newWord = ""            //resets new word
        usedWords.removeAll()   //removes all previous entries
        score = 0               //adding score feature
        
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
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
