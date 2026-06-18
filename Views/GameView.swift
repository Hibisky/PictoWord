
struct GameQuestion {
    let question: Question     // la question originale (image, mot correct…)
    let choices: [String]      // 4 mots mélangés, prêts à afficher
    
    var correctWord: String { question.correctWord }
    var imageName: String { question.imageName }
}