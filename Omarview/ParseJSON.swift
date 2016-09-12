//
//  ParseJSON.swift
//  Omarview
//
//  Created by Kelly Tan on 9/10/16.
//  Copyright © 2016 Lucy Chai. All rights reserved.
//

import Foundation
import SwiftyJSON

func parseLines(_ textJson: JSON) -> [PosterLine] {
    
    let responses: JSON = textJson["responses"][0]
    
    var lines = [PosterLine]()
    var lineCount = 0
    var currLine = 0
    var currCount = 0
    
    if let textAnnotations: JSON = responses["textAnnotations"] {
        let nodeCount: Int = textAnnotations.count
        if nodeCount > 0 {
            for index in 0...(nodeCount - 1) {
                let description = textAnnotations[index]["description"].stringValue
                if description.range(of: "\n") != nil {
                    let lineText = description.components(separatedBy: "\n")
                    for line in lineText {
                        lines.append(PosterLine.init(text: line))
                    }
                    lineCount = lines[currLine].text.components(separatedBy: " ").count
                } else {
                    if currCount >= lineCount {
                        currLine += 1
                        lineCount = lines[currLine].text.components(separatedBy: " ").count
                        currCount = 0
                    }
                    
                    let vertices = textAnnotations[index]["boundingPoly"]["vertices"]
                    let vertexCount: Int = vertices.count
                    if vertexCount > 0 {
                        for vIndex in 0...(vertexCount - 1) {
                            let x = vertices[vIndex]["x"].intValue
                            let y = vertices[vIndex]["y"].intValue
                            
                            if x < lines[currLine].minX {
                                lines[currLine].minX = x
                            }
                            if x > lines[currLine].maxX {
                                lines[currLine].maxX = x
                            }
                            if y < lines[currLine].minY {
                                lines[currLine].minY = y
                            }
                            if y > lines[currLine].maxY {
                                lines[currLine].maxY = y
                            }
                        }
                    }
                    currCount += 1
                }
            }
        }
    }

    return lines
}
