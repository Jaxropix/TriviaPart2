
import Foundation

class TriviaQuestionService {
    static let shared = TriviaQuestionService()
    
    private init() {}
    
    func fetchTriviaQuestions(amount: Int = 5, completion: @escaping ([TriviaQuestion]?, Error?) -> Void) {
        let urlString = "https://opentdb.com/api.php?amount=\(amount)"
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "InvalidURL", code: 0, userInfo: nil))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let triviaResponse = try decoder.decode(TriviaResponse.self, from: data)
                
                // Convert HTML entities in questions before returning
                let questions = triviaResponse.results.map { question in
                    return TriviaQuestion(category: question.category,
                                           question: question.question.convertHTMLEntities() ?? "",
                                           correctAnswer: question.correctAnswer,
                                           incorrectAnswers: question.incorrectAnswers.map { $0.convertHTMLEntities() ?? "" })
                }
                
                completion(questions, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
}

extension String {
    func convertHTMLEntities() -> String? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        
        do {
            let attributedString = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
            return attributedString.string
        } catch {
            print("Error converting HTML entities: \(error)")
            return nil
        }
    }
}
