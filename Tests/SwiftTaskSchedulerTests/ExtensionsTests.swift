import XCTest
@testable import SwiftTaskScheduler

final class ExtensionsTests: XCTestCase {
    func testFilterSequenceUniqueElements() {
        let array = [0, 1, 2, 2, 3, 4, 5, 5] // 8 elements
        let uniqueElements = array.unique { $0 } // would be 6 elements
        XCTAssertEqual(uniqueElements.count, 6)
        XCTAssertEqual(uniqueElements, [0, 1, 2, 3, 4, 5])
    }
    
    func testDateAsDateStructure() throws {
        let date = Date.now
        let calendar = Calendar(identifier: .gregorian)
        
        let dateComponents = calendar
            .dateComponents([.year, .month, .day, .weekday, .hour, .minute, .second], from: date)
        
        let dateStructure = date.asDateStructure(calendar)
        
        XCTAssertEqual(dateComponents.year!, dateStructure.year)
        XCTAssertEqual(dateComponents.month!, dateStructure.month)
        XCTAssertEqual(dateComponents.day!, dateStructure.day)
        XCTAssertEqual(dateComponents.weekday!, dateStructure.weekday)
        XCTAssertEqual(dateComponents.hour!, dateStructure.hours)
        XCTAssertEqual(dateComponents.minute!, dateStructure.minutes)
        XCTAssertEqual(dateComponents.second!, dateStructure.seconds)
    }
    
    func testIntTimeUnitRepresentable() {
        XCTAssertEqual(1.seconds, 1)
        XCTAssertEqual(1.minutes, 60)
        XCTAssertEqual(1.hours, 3600)
        XCTAssertEqual(1.days, 86400)
    }
    
    func testDoubleTimeUnitRepresentable() {
        XCTAssertEqual(0.5.seconds, 0.5)
        XCTAssertEqual(0.5.minutes, 30)
        XCTAssertEqual(0.5.hours, 1800)
        XCTAssertEqual(0.5.days, 43200)
    }
}
