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
 
 QnA Service Helpers Struct
 
 Helpers to work with the QnA Service Input and Output
 
 */
fileprivate struct serviceHelpers {
    static func validResults(dict: NSDictionary) -> Bool {
        if dict["answers"] != nil {
            return true
        }
        if dict["error"] != nil {
            return true
        }
        
        return false
    }
    
    static func hasError(dict: NSDictionary) -> Bool {
        return dict["error"] != nil
    }
    
    static func buildError(dict: NSDictionary, statusCode: Int) -> QnAError {
        let errorObj = dict["error"] as! NSDictionary
        let errorTile = errorObj["code"] as! String
        let messages = errorObj["message"] as! [String]
        return QnAError(localizedTitle: errorTile, localizedDescription: messages.first ?? "error", code: statusCode)
    }
    
    // Microsoft QnA provides the requests in HTML format.  The below decodes the provided string into one that we can work with in Swift.
    // This method is a fork of the one provided in the below stackoverflow post.
    // https://stackoverflow.com/questions/25607247/how-do-i-decode-html-entities-in-swift
    static func htmlDecoded(input: String)->String {
        guard input.count > 0 else { return input }
        guard let encodedData = input.data(using: .utf8) else { return input }
        
        let attributedOptions: [NSAttributedString.DocumentReadingOptionKey : Any] = [
            NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
            NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8]
        
        do {
            return try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil).string
        } catch {
            print("Error: \(error)")
            return input
        }
    }
    
    static func buildAnswers(dict: NSDictionary) -> [QnAAnswer] {
        var answers = [QnAAnswer]()
        let items = dict["answers"] as! NSArray
        for item in items {
            let raw = item as! NSDictionary
            let answer = htmlDecoded(input: raw["answer"] as! String)
            let questions = raw["questions"] as! [String]
            let score = raw["score"] as! Int
            answers.append(QnAAnswer(answer: answer, questions: questions, score: score))
        }
        return answers
    }
}

/**
 
 QnA Service class
 
 Provides the ability to ask the Microsoft QnA Maker Service a query
 
 */
open class QnAService {
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
    public init(knowledgebaseID: String, subscriptionKey: String, config: QnAConfigProtocol = QnAConfigDefault()) {
        let kbKey = knowledgebaseID.trimmingCharacters(in: .whitespacesAndNewlines)
        kbURL = "/knowledgebases/\(kbKey)/generateAnswer"
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
    
    /**
     The ask method allows you to ask a question of your Microsoft QnA Service
     
     - Parameter question: The question you are asking
     - Parameter completionHandler: The completion handler with answer or error provided from the service
     */
    open func askQuestion(_ question: String, completionHandler: @escaping ([QnAAnswerProtocol]?, QnAErrorProtocol?) -> Void) {
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
                    
                    guard serviceHelpers.validResults(dict: results) else {
                        return completionHandler(nil, QnAError(localizedTitle: "error", localizedDescription: "Invalid API Results provided", code: httpResponse.statusCode))
                    }
                    
                    if serviceHelpers.hasError(dict: results) {
                        return completionHandler(nil, serviceHelpers.buildError(dict: results, statusCode: httpResponse.statusCode))
                    }
                    return completionHandler(serviceHelpers.buildAnswers(dict: results), nil)
                }
                
            } catch {
                return completionHandler(nil, QnAError(localizedTitle: "error", localizedDescription: error.localizedDescription, code: httpResponse.statusCode))
            }
            
            
        })
        task.resume()
    }
}
