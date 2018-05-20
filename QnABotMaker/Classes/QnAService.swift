/*
 
 Project: QnABotMaker
 Description: Convenience library for working with Microsoft's QnA Maker Service
 
 MIT License
 
 Copyright (c) 2018 Ben Bahrenburg @bencoding
 
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
 
 QnA Service class
 
 Provides the ability to ask the Microsoft QnA Maker Service a query
 
 */
open class QnAService {
    fileprivate let endpointKey: String!
    fileprivate let serviceURL: String!
    fileprivate let knowledgebaseID: String!
    fileprivate let session: URLSession!
    
    /**
     Creates a new instance of the QnABotMaker struct
     
     - Parameter host: The host url for yourhttps://qnamaker.ai service
     - Parameter knowledgebaseID: The knowledgebase identifier used in your generateAnswer url https://qnamaker.ai service
     - Parameter endpointKey: Your EndpointKey guid
     - Parameter sessionConfiguration: An optional URLSessionConfiguration for your connection
     */
    public init(host: String, knowledgebaseID: String, endpointKey: String, sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default) {
        self.serviceURL = "\(host)/knowledgebases/\(knowledgebaseID)/generateAnswer/"
        self.knowledgebaseID = knowledgebaseID
        self.endpointKey = endpointKey
        session = URLSession(configuration: sessionConfiguration) // Load configuration into Session
    }
    
    /**
     The ask method allows you to ask a question of your Microsoft QnA Service
     
     - Parameter question: The question you are asking
     - Parameter completionHandler: The completion handler with answer or error provided from the service
     */
    open func askQuestion(_ question: String, completionHandler: @escaping ([QnAAnswerProtocol]?, QnAErrorProtocol?) -> Void) {
        guard let url = serviceURL else {
            return completionHandler(nil, QnAError(localizedTitle: "error", localizedDescription: "Invalid URL: Unabled to create API URL", code: 0))
        }
        
        guard let authorizationKey = endpointKey else {
            return completionHandler(nil, QnAError(localizedTitle: "error", localizedDescription: "Missing Authorization Key", code: 0))
        }
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("EndpointKey \(authorizationKey)", forHTTPHeaderField: "Authorization")
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
                    
                    guard ServiceHelpers.validResults(dict: results) else {
                        return completionHandler(nil, QnAError(localizedTitle: "error", localizedDescription: "Invalid API Results provided", code: httpResponse.statusCode))
                    }
                    
                    if ServiceHelpers.hasError(dict: results) {
                        return completionHandler(nil, ServiceHelpers.buildError(dict: results, statusCode: httpResponse.statusCode))
                    }
                    return completionHandler(ServiceHelpers.buildAnswers(dict: results), nil)
                }
                
            } catch {
                return completionHandler(nil, QnAError(localizedTitle: "error", localizedDescription: error.localizedDescription, code: httpResponse.statusCode))
            }
            
            
        })
        task.resume()
    }
}
