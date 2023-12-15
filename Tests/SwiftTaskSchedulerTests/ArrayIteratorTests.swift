import XCTest
@testable import SwiftTaskScheduler

final class ArrayIteratorTests: XCTestCase {
    func testMakeArrayIteratorReturnsNotNil() {
        let array = [0]
        let iterator = array.makeArrayIterator()
        XCTAssertNotNil(iterator)
    }
    
    func testCurrentElementIsNilAtStartPosition() {
        let array = [0]
        let iterator = array.makeArrayIterator()
        XCTAssertNil(iterator.current)
    }
    
    func testHasNextElementReturnsTrueWhenNextElementExists() {
        let array = [0]
        let iterator = array.makeArrayIterator()
        XCTAssertTrue(iterator.hasNext)
    }
    
    func testCurrentElementIsNotNilWhenIteratorPositionAtExistsElement() {
        let array = [0]
        let iterator = array.makeArrayIterator()
        
        let element = iterator.next()
        
        XCTAssertNotNil(iterator.current)
        XCTAssertEqual(element, 0)
    }
    
    func testHasNextElementReturnsFalseWhenCurrentElementIsLast() {
        let array = [0]
        let iterator = array.makeArrayIterator()
        
        _ = iterator.next()
        
        XCTAssertFalse(iterator.hasNext)
    }
    
    func testIteratorDropPosition() {
        let array = [0]
        let iterator = array.makeArrayIterator()
        
        _ = iterator.next()
        
        iterator.drop()
        
        XCTAssertTrue(iterator.hasNext)
        XCTAssertNil(iterator.current)
    }
}
