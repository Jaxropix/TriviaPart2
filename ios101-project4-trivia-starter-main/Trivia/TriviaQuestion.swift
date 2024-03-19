import Foundation

struct TriviaResponse: Decodable {
    let results: [TriviaQuestion]
}

struct TriviaQuestion: Decodable {
    let category: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
}

