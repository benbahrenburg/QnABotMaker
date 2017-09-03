/*

 Project: QnABotMaker
 Description: Convenience library for working with Microsoft's QnA Maker Service
 
 MIT License
 
 Copyright (c) 2017 Ben Bahrenburg @bencoding
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation

/**
 
QnA Bot Maker Struct
 
 Provides the ability to ask the Microsoft QnA Maker Service a query
 
 */
public struct QnABotMaker {
    fileprivate let kbURL: String!
    fileprivate let subscriptionKey: String!
    fileprivate let session: URLSession!
    fileprivate let config: QnAConfigProtocol!

    /**
     Creates a new instance of the QnABotMaker struct
     
     - Parameter knowledgebaseID: The knowledgebase id for your https://qnamaker.ai service
     - Parameter subscriptionKey: The Ocp-Apim-Subscription-Key for your https://qnamaker.ai service
     - Parameter config: An optional configuration protocol see QnAConfigProtocol for details
     */
    init(knowledgebaseID: String, subscriptionKey: String, config: QnAConfigProtocol = QnAConfigDefault()) {
        let kbKey = knowledgebaseID.trimmingCharacters(in: .whitespacesAndNewlines)
        kbURL = " /knowledgebases/\(kbKey)/generateAnswer"
        self.subscriptionKey = subscriptionKey
        self.config = config
        session = URLSession(configuration: config.sessionConfig) // Load configuration into Session
    }
    
    private func getURL() -> URL? {
        let template = "\(config.hostUrl)\(kbURL!)"
        guard let url = URL(string: template) else {
            return nil
        }
        return url
    }
    
    private func validResults(dict: NSDictionary) -> Bool {
        if dict["answers"] != nil {
            return true
        }
        if dict["error"] != nil {
            return true
        }
        
        return false
    }
    
    private func hasError(dict: NSDictionary) -> Bool {
        return dict["error"] != nil
    }
    
    private func buildError(dict: NSDictionary, statusCode: Int) -> QnAError {
        let errorObj = dict["error"] as! NSDictionary
        let errorTile = errorObj["code"] as! String
        let messages = errorObj["message"] as! [String]
        return QnAError(localizedTitle: errorTile, localizedDescription: messages.first ?? "error", code: statusCode)
    }
    
    private func buildAnswers(dict: NSDictionary) -> [QnAAnswer] {
        var answers = [QnAAnswer]()
        let items = dict["answers"] as! NSArray
        for item in items {
            let raw = item as! NSDictionary
            let answer = raw["answer"] as! String
            let questions = raw["questions"] as! [String]
            let score = raw["score"] as! Int
            answers.append(QnAAnswer(answer: answer, questions: questions, score: score))
        }
        return answers
    }

    /**
     The ask method allows you to ask a question of your Microsoft QnA Service
     
     - Parameter question: The question you are asking
     - Parameter completionHandler: The completion handler with answer or error provided from the service
     */
    func ask(_ question: String, completionHandler: @escaping ([QnAAnswerProtocol]?, QnAErrorProtocol?) -> Void) {
        guard let url = getURL() else {
            return completionHandler(nil, QnAError(localizedTitle: "error", localizedDescription: "Invalid URL: Unabled to create API URL", code: 0))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        
        let params = ["question" : question]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return completionHandler(nil, QnAError(localizedTitle: "error", localizedDescription: "Unable to serialize parameters", code: 0))
        }
        request.httpBody = httpBody
        
        let task = session.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) in
            guard let httpResponse = response as? HTTPURLResponse else {
                return completionHandler(nil, QnAError(localizedTitle: "error", localizedDescription: "No HTTP status code returned", code: 0))
            }
            
            guard error == nil else {
                return completionHandler(nil, QnAError(localizedTitle: "error", localizedDescription: error!.localizedDescription, code: httpResponse.statusCode))
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                    let results = json as NSDictionary
                    
                    guard self.validResults(dict: results) else {
                        return completionHandler(nil, QnAError(localizedTitle: "error", localizedDescription: "Invalid API Results provided", code: httpResponse.statusCode))
                    }
                    
                    if self.hasError(dict: results) {
                        return completionHandler(nil, self.buildError(dict: results, statusCode: httpResponse.statusCode))
                    }
                    return completionHandler(self.buildAnswers(dict: results), nil)
                }
                
            } catch {
                return completionHandler(nil, QnAError(localizedTitle: "error", localizedDescription: error.localizedDescription, code: httpResponse.statusCode))
            }
            
            
        })
        task.resume()
    }
}
