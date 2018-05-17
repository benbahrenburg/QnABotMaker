//
//  QnAServiceHelpers.swift
//  Pods-QnABotMaker_Example
//
//  Created by Ben Bahrenburg on 5/16/18.
//

import UIKit

/**
 
 QnA Service Helpers Struct
 
 Helpers to work with the QnA Service Input and Output
 
 */
internal struct serviceHelpers {
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
        print(dict)
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
            NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html.rawValue,
            NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue]
        
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
            let score = raw["score"] as! Double
            answers.append(QnAAnswer(answer: answer, questions: questions, score: score))
        }
        return answers
    }
}
