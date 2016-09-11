//
//  PosterLine.swift
//  Omarview
//
//  Created by Kelly Tan on 9/10/16.
//  Copyright © 2016 Lucy Chai. All rights reserved.
//

import Foundation

class PosterLine {
    var text: String
    var minX: Int = Int.max
    var maxX: Int = Int.min
    var minY: Int = Int.max
    var maxY: Int = Int.min
    
    init(text: String) {
        self.text = text
    }
    
    func width() -> Int {
        if maxX > minX {
            return maxX - minX
        }
        return 0
    }
    
    func height() -> Int {
        if maxY > minY {
            return maxY - minY
        }
        return 0
    }
    
}