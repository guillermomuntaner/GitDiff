//
//  GitDiffTests.swift
//  GitDiffViewTests
//
//  Created by Guillermo Muntaner Perelló on 03/10/2018.
//  Copyright © 2018 Guillermo Muntaner. All rights reserved.
//

import XCTest
@testable import GitDiff

class GitDiffTests: XCTestCase {
    
    let unifiedGitDiff = """
    --- /path/to/original
    +++ /path/to/new
    @@ -1,3 +1,9 @@
    +This is an important
    +notice! It should
    +therefore be located at
    +the beginning of this
    +document!
    +
     This part of the
     document has stayed the
     same from version to
    @@ -8,13 +14,8 @@
     compress the size of the
     changes.
     
    -This paragraph contains
    -text that is outdated.
    -It will be deleted in the
    -near future.
    -
     It is important to spell
    -check this dokument. On
    +check this document. On
     the other hand, a
     misspelled word isn't
     the end of the world.
    @@ -22,3 +23,7 @@
     this paragraph needs to
     be changed. Things can
     be added after it.
    +
    +This paragraph contains
    +important new additions
    +to this document.
    """
    
    var gitDiff: GitDiff!
    
    override func setUp() {
        gitDiff = try! GitDiff(unifiedDiff: unifiedGitDiff)
    }
    
    override func tearDown() {
    }
    
    func testGitDiffDeserialization() {
        XCTAssertEqual(gitDiff.removedFile, "/path/to/original")
        XCTAssertEqual(gitDiff.addedFile, "/path/to/new")
        XCTAssertEqual(gitDiff.hunks.count, 3)
        let hunksAndExpectations: [(GitDiffHunk, (oldLineStart: Int, oldLineSpan: Int, newLineStart: Int, newLineSpan: Int, numberOfLines: Int))] = [
            (gitDiff.hunks[0], (1,3,1,9,9)),
            (gitDiff.hunks[1], (8,13,14,8,14)),
            (gitDiff.hunks[2], (22,3,23,7,7)),
            ]
        hunksAndExpectations.forEach { (hunk, hunkExpectation) in
            XCTAssertEqual(hunk.oldLineStart, hunkExpectation.oldLineStart)
            XCTAssertEqual(hunk.oldLineSpan, hunkExpectation.oldLineSpan)
            XCTAssertEqual(hunk.newLineStart, hunkExpectation.newLineStart)
            XCTAssertEqual(hunk.newLineSpan, hunkExpectation.newLineSpan)
            XCTAssertEqual(hunk.lines.count, hunkExpectation.numberOfLines)
        }
    }
    
    func testGitDiffSerialization() {
        XCTAssertEqual(gitDiff.description, unifiedGitDiff)
    }
    
    func testPerformanceExample() {
        self.measure {
            _ = try! GitDiff(unifiedDiff: unifiedGitDiff)
        }
    }
    
}
