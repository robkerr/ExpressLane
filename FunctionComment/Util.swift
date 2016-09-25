//**************************************************************************************
//
//    Filename: Util.swift
//     Project: ExpressLane
//
//      Author: Robert Kerr 
//   Copyright: Copyright © 2016 Mobile Toolworks. All rights reserved.
//
//  Maintenance History
//          9/25/16      File Created
//
//**************************************************************************************

import Foundation

class Util {
    
    //**************************************************************************************
    //
    //      Function: findFirstCharacterIndex
    //   Description: Scans the beginning of a string, and returns the index for the
    //                first printable character
    //
    //**************************************************************************************
    static func findFirstCharacterIndex(str : String) -> Int? {
        // find first character in line that is not ' ' or '/'
        var index : Int? = nil
        for i in stride(from: 0, to: str.characters.count, by: 1) {
            if ![" ", "/"].contains(str[str.index(str.startIndex, offsetBy: i)]) {
                index = i
                break
            }
        }
        return index
    }
    
}
