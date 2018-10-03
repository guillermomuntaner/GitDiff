//
//  GitDiffParser.swift
//  GitDiff
//
//  Created by Guillermo Muntaner Perelló on 03/10/2018.
//

import Foundation

internal class GitDiffParser {
    
    /// Regex for parsing git diffs.
    ///
    /// - Group 0:
    ///
    let regex = try! NSRegularExpression(
        pattern: "^(?:(?:@@ -(\\d+),(\\d+) \\+(\\d+),(\\d+) @@)|([-+\\s])(.*))",
        options: [])
    
    let unifiedDiff: String
    
    init(unifiedDiff: String) {
        self.unifiedDiff = unifiedDiff
    }
    
    func parse() throws -> (addedFile: String, removedFile: String, hunks: [GitDiffHunk]) {
        
        var addedFile: String?
        var removedFile: String?
        
        var hunks: [GitDiffHunk] = []
        var currentHunk: GitDiffHunk?
        
        unifiedDiff.enumerateLines { line, _ in
            // Skip headers
            guard !line.starts(with: "+++ ") else {
                addedFile = String(line.dropFirst(4))
                return
            }
            guard !line.starts(with: "--- ") else {
                removedFile = String(line.dropFirst(4))
                return
            }
            
            if let match = self.regex.firstMatch(in: line, options: [], range: NSMakeRange(0, line.utf16.count)) {
                
                if let oldLineStartString = match.group(1, in: line), let oldLineStart = Int(oldLineStartString),
                    let oldLineSpanString = match.group(2, in: line), let oldLineSpan = Int(oldLineSpanString),
                    let newLineStartString = match.group(3, in: line), let newLineStart = Int(newLineStartString),
                    let newLineSpanString = match.group(4, in: line), let newLineSpan = Int(newLineSpanString) {
                    
                    if let currentHunk = currentHunk {
                        hunks.append(currentHunk)
                    }
                    
                    currentHunk = GitDiffHunk(
                        oldLineStart: oldLineStart,
                        oldLineSpan: oldLineSpan,
                        newLineStart: newLineStart,
                        newLineSpan: newLineSpan,
                        lines: [])
                    
                } else if let delta = match.group(5, in: line),
                    let text = match.group(6, in: line) {
                    
                    guard let hunk = currentHunk else {
                        fatalError("Found a git diff line without a hunk header")
                    }
                    
                    let lineType: GitDiffHunkLineType
                    switch delta {
                    case "-": lineType = .deletion
                    case "+": lineType = .addition
                    case " ": lineType = .unchanged
                    default: fatalError("Unexpected group 2 character: \(delta)")
                    }
                    
                    currentHunk = hunk.copyAppendingLine(GitDiffHunkLine(type: lineType, text: text))
                }
            }
        }
        
        // Append last hunk
        if let currentHunk = currentHunk {
            hunks.append(currentHunk)
        }
        
        guard let added = addedFile, let removed = removedFile else {
            fatalError("Couldn't find +++ &/or --- files")
        }
        
        return (addedFile: added, removedFile: removed, hunks: hunks)
    }
}

internal extension NSTextCheckingResult {
    
    func group(_ group: Int, in string: String) -> String? {
        let nsRange = range(at: group)
        if range.location != NSNotFound {
            return Range(nsRange, in: string)
                .map { range in String(string[range]) }
        }
        return nil
    }
}
