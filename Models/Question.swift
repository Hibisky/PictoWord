// Models/Question.swift
import Foundation

struct Question: Identifiable {
    var id: String
    var imageName: String
    var correctWord: String
    var level: Int
    var theme: String
    var difficulty: String
    var hint: String
    var funFact: String
    var tags: [String]
}

