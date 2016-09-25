//**************************************************************************************
//
//    Filename: FunctionCommentCommand.swift
//     Project: FunctionComment
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

class FunctionCommentCommand: NSObject, XCSourceEditorCommand {
    
    //**************************************************************************************
    //
    //      Function: perform
    //   Description: Entry point called when users runs the function from the Editor menu
    //
    //**************************************************************************************
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        //var newSelections = [XCSourceTextRange]()
        let buffer = invocation.buffer
        
        buffer.selections.forEach({ selection in
                guard let selection = selection as? XCSourceTextRange,
                    selection.start.line == selection.end.line else { return }
                
                let line = buffer.lines[selection.start.line] as! String
                let startIndex = line.characters.index(
                    line.startIndex, offsetBy: selection.start.column)
                let endIndex = line.characters.index(
                    line.startIndex, offsetBy: selection.end.column)
                
                let selectedText = line.substring(with:
                    startIndex..<line.index(after: endIndex))
            
                // Determine what characters to place before the comment, if any
                var prefix = ""
                if let textStart = Util.findFirstCharacterIndex(str: line) {
                    if textStart > 0 {
                        prefix = line[0...textStart-1]
                    }
                }
                
                
                let commentBorder =       "\(prefix)//**************************************************************************************"
                let commentBlankLine =    "\(prefix)//"
                let commentFunctionName = "\(prefix)//      Function: \(selectedText)"
                let commentDescription =  "\(prefix)//   Description: "
                
                let newLines = [commentBorder, commentBlankLine, commentFunctionName, commentDescription, commentBlankLine, commentBorder]
                
                let startLine = selection.start.line
                buffer.lines.insert(newLines, at: IndexSet(startLine ..< startLine + newLines.count))
            })
        
        
        
        completionHandler(nil)
    }
    

}
