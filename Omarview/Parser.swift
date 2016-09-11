//
//  Parser.swift
//  Omarview
//
//  Created by Eric Li on 9/10/16.
//  Copyright © 2016 Lucy Chai. All rights reserved.
//

import Foundation

func parseDateFromStr(str: String) ->  NSTextCheckingResult? {
    let types: NSTextCheckingType = [.Date]
    let detector = try? NSDataDetector(types: types.rawValue)
    
    let match = detector?.firstMatchInString(str, options: [], range: NSMakeRange(0, (str as NSString).length))
    
    if let m = match {
        if (m.resultType == NSTextCheckingType.Date) {
            return m
        }
    }
    return Optional.None
}

func parseUrlFromStr(str: String) -> NSURL? {
    let matches = matchesForRegexInText("([wW]{3}\\.)?\\w+\\.(com|edu|org|net|gov)(\\.|(/\\w*)+/*)", text: str.stringByReplacingOccurrencesOfString(" ", withString: ".").stringByReplacingOccurrencesOfString("\n", withString: ".") + ".")
    if matches.count > 0 {
        var url = matches[0]
        if url.characters.last == "." {
            url = url.substringToIndex(url.endIndex.advancedBy(-1))
        }
        return NSURL(string: url)
    }
    return Optional.None
}

func matchesForRegexInText(regex: String, text: String) -> [String] {
    
    do {
        let regex = try NSRegularExpression(pattern: regex, options: [])
        let nsString = text as NSString
        let results = regex.matchesInString(text,
                                            options: [], range: NSMakeRange(0, nsString.length))
        return results.map { nsString.substringWithRange($0.range)}
    } catch let error as NSError {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}

func parseAddrFromStr(str: String) -> NSTextCheckingResult? {
    let detector = try! NSDataDetector(types: NSTextCheckingType.Address.rawValue)
    let match = detector.firstMatchInString(str, options: [], range: NSRange(location: 0, length: str.utf16.count))
    
    if let m = match {
        if (m.resultType == NSTextCheckingType.Address) {
            return m
        }
    }
    return Optional.None
}
