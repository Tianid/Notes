

import XCTest
@testable import Notes
class NotesTests: XCTestCase {
    var note = Note(title: "1", content: "1", importance: .important)
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testNoteInit() {
        
        XCTAssertEqual(UIColor.white, note.color)
        XCTAssertNil(note.selfDestructionDate)
    }
    
    func testJson() {
        let json = note.json
        XCTAssertLessThan(0, json.count)
    }
    
    func testParse() {
        let json = note.json
        XCTAssertNotNil(Note.parse(json: json))
    }
}
