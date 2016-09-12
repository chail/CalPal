//
//  Parser.swift
//  Omarview
//
//  Created by Eric Li on 9/10/16.
//  Copyright © 2016 Lucy Chai. All rights reserved.
//

import Foundation

func parseDateFromStr(_ str: String) ->  NSTextCheckingResult? {
    let types: NSTextCheckingResult.CheckingType = [.date]
    let detector = try? NSDataDetector(types: types.rawValue)
    
    let match = detector?.firstMatch(in: str, options: [], range: NSMakeRange(0, (str as NSString).length))
    
    if let m = match {
        if (m.resultType == NSTextCheckingResult.CheckingType.date) {
            return m
        }
    }
    return Optional.none
}

func parseUrlFromStr(_ str: String) -> URL? {
    let matches = matchesForRegexInText("([wW]{3}\\.)?\\w+\\.(com|edu|org|net|gov)(\\.|(/\\w*)+/*)", text: str.replacingOccurrences(of: " ", with: ".").replacingOccurrences(of: "\n", with: ".") + ".")
    if matches.count > 0 {
        var url = matches[0]
        if url.characters.last == "." {
            url = url.substring(to: url.characters.index(url.endIndex, offsetBy: -1))
        }
        return URL(string: url)
    }
    return Optional.none
}

func matchesForRegexInText(_ regex: String, text: String) -> [String] {
    
    do {
        let regex = try NSRegularExpression(pattern: regex, options: [])
        let nsString = text as NSString
        let results = regex.matches(in: text,
                                            options: [], range: NSMakeRange(0, nsString.length))
        return results.map { nsString.substring(with: $0.range)}
    } catch let error as NSError {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}

func parseAddrFromStr(_ str: String) -> NSTextCheckingResult? {
    let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.address.rawValue)
    let match = detector.firstMatch(in: str, options: [], range: NSRange(location: 0, length: str.utf16.count))
    
    if let m = match {
        if (m.resultType == NSTextCheckingResult.CheckingType.address) {
            return m
        }
    }
    return Optional.none
}
