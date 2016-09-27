//**************************************************************************************
//
//    Filename: FileCommentCommand.swift
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
import XcodeKit

extension String {
    subscript(i: Int) -> String {
        guard i >= 0 && i < characters.count else { return "" }
        return String(self[index(startIndex, offsetBy: i)])
    }
    subscript(range: Range<Int>) -> String {
        let lowerIndex = index(startIndex, offsetBy: max(0,range.lowerBound), limitedBy: endIndex) ?? endIndex
        return substring(with: lowerIndex..<(index(lowerIndex, offsetBy: range.upperBound - range.lowerBound, limitedBy: endIndex) ?? endIndex))
    }
    subscript(range: ClosedRange<Int>) -> String {
        let lowerIndex = index(startIndex, offsetBy: max(0,range.lowerBound), limitedBy: endIndex) ?? endIndex
        return substring(with: lowerIndex..<(index(lowerIndex, offsetBy: range.upperBound - range.lowerBound + 1, limitedBy: endIndex) ?? endIndex))
    }
}


class FileCommentCommand: NSObject, XCSourceEditorCommand {
    
    let commentBorder =       "//**************************************************************************************"
    let commentBlankLine =    "//"
    
    //**************************************************************************************
    //
    //      Function: perform
    //   Description: Entry point called by XCode when the user selects the command 
    //                  from the Editor menu
    //
    //**************************************************************************************
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        //var newSelections = [XCSourceTextRange]()
        let buffer = invocation.buffer
        
        var fileName = ""
        var projectName = ""
        var createdBy = ""
        var createdDate = ""
        var copyright = ""

        var linesToDelete = IndexSet()
        
        // Delete out the existing "//" lines at the top of the file, while scavenging the existing comment lines
        for lineNum in stride(from: 0, to: buffer.lines.count, by: 1) {
            
            if let str = buffer.lines[lineNum] as? String {
                
                // If this line doesn't begin with "//" then break out, because we have passed by the existing header
                if !str.hasPrefix("//") {
                    break
                }
                
                // This line begins with a comment, so delete it
                //linesToDelete.append(lineNum)
                linesToDelete.insert(lineNum)
                
                // pull out filename
                if str.hasSuffix("swift\n") {
                    
                    if let index = Util.findFirstCharacterIndex(str: str) {
                        fileName = str[index...str.characters.count-2]
                        
                        // The following line will be the project name (if there is a following line)
                        if lineNum+1 < buffer.lines.count {
                            if let str = buffer.lines[lineNum+1] as? String {
                                if let startIndex = Util.findFirstCharacterIndex(str: str) {
                                    projectName = str[startIndex...str.characters.count-2]
                                }
                            }
                        }
                    }
                }
                
                // pull out the Author line
                if str.contains("Created by") {
                    createdBy = getAuthorName(str: str)
                    createdDate = getCreateDate(str: str)
                }
                
                // pull out the Copyright line
                if str.contains("Copyright") {
                    if let startIndex = Util.findFirstCharacterIndex(str: str) {
                        copyright = str[startIndex...str.characters.count-2]
                    }
                }
            }

        }
        
        // Remove the lines at top of file that begin with "//"
        buffer.lines.removeObjects(at: linesToDelete)
        
        
        // use today's date if thee date wasn't found in the header
        if createdDate == "" {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            createdDate = df.string(from: Date())
        }
        
        // Add new file header to top of file
        var newLines = [String]()
        
        newLines.append(commentBorder)
        newLines.append(commentBlankLine)
        newLines.append("//    Filename: \(fileName)")
        newLines.append("//     Project: \(projectName)")
        newLines.append(commentBlankLine)
        newLines.append("//      Author: \(createdBy)")
        newLines.append("//   Copyright: \(copyright)")
        newLines.append(commentBlankLine)
        newLines.append("// Description: ")
        newLines.append(commentBlankLine)
        newLines.append("//  Maintenance History")
        newLines.append("//          \(createdDate)      File Created")
        newLines.append(commentBlankLine)
        newLines.append(commentBorder)
        
        // Add new file header
        buffer.lines.insert(newLines, at: IndexSet(0 ..< newLines.count))
        
        
        completionHandler(nil)
    }
    
    
    //**************************************************************************************
    //
    //      Function: getAuthorName
    //   Description: Scan a standard XCode file header line and return Author's name only
    //
    //**************************************************************************************
    func getAuthorName(str : String) -> String {
        
        var s = ""
        
        if let nameStart = str.range(of: "Created by ")?.upperBound {
            if let nameEnd = str.range(of: " on ")?.lowerBound {
                
                s = str[nameStart...nameEnd]
                
            }
        }
        return s
    }
    
    //**************************************************************************************
    //
    //      Function: getCreateDate
    //   Description: Scan a standard XCode file header line and return Create Date only
    //
    //**************************************************************************************
    func getCreateDate(str : String) -> String {
        
        var s = ""
        
        if let nameStart = str.range(of: " on ")?.upperBound {
            if let nameEnd = str.range(of: ".")?.lowerBound {
                
                let pos1 = str.characters.distance(from: str.startIndex, to: nameStart)
                let pos2 = str.characters.distance(from: str.startIndex, to: nameEnd) - 1
                s = str[pos1...pos2]
                
            }
        }
        return s
    }
}
