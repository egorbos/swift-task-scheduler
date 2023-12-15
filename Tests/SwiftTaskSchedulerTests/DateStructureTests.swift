import XCTest
@testable import SwiftTaskScheduler

final class DateStructureTests: XCTestCase {
    let testDateStructure = DateStructure(
        year: 2023, month: 12, day: 5, weekday: 3, hours: 1, minutes: 1, seconds: 1
    )
    
    func testDateStructureWithNewTime() {
        let dateStructureWithTime = testDateStructure.with(hours: 2, minutes: 2, seconds: 2)
        
        XCTAssertEqual(dateStructureWithTime.hours, 2)
        XCTAssertEqual(dateStructureWithTime.minutes, 2)
        XCTAssertEqual(dateStructureWithTime.seconds, 2)
    }
    
    func testDayOfDateStructureIncludeTime() {
        // 00:00:00 not included in day with 01:01:01 time
        XCTAssertFalse(testDateStructure.isInclude(time: .init(hours: 0, minutes: 0, seconds: 0)))
        // 01:01:01 not included in day with 01:01:01 time
        XCTAssertFalse(testDateStructure.isInclude(time: .init(hours: 1, minutes: 1, seconds: 1)))
        // 01:01:02 included in day with 01:01:01 time
        XCTAssertTrue(testDateStructure.isInclude(time: .init(hours: 1, minutes: 1, seconds: 2)))
        // 03:03:03 included in day with 01:01:01 time
        XCTAssertTrue(testDateStructure.isInclude(time: .init(hours: 3, minutes: 3, seconds: 3)))
    }
    
    func testConvertDateStructureToDate() {
        let calendar = Calendar(identifier: .gregorian)
        
        let dateFromStructure = testDateStructure.asDate(calendar)
        let dateComponents = calendar
            .dateComponents([.year, .month, .day, .weekday, .hour, .minute, .second], from: dateFromStructure)
        
        XCTAssertEqual(dateComponents.year!, testDateStructure.year)
        XCTAssertEqual(dateComponents.month!, testDateStructure.month)
        XCTAssertEqual(dateComponents.day!, testDateStructure.day)
        XCTAssertEqual(dateComponents.weekday!, testDateStructure.weekday)
        XCTAssertEqual(dateComponents.hour!, testDateStructure.hours)
        XCTAssertEqual(dateComponents.minute!, testDateStructure.minutes)
        XCTAssertEqual(dateComponents.second!, testDateStructure.seconds)
    }
}
