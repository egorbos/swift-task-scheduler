import XCTest
@testable import SwiftTaskScheduler

final class ExecutionStrategyTests: XCTestCase {

    let decoder = JSONDecoder()
    
    func testDecodeOnceExecutionStrategyFromJson() throws {
        let data = try JSONSerialization.data(withJSONObject: [
            "type" : 0,
            "time" : [["hours": 15, "minutes": 30, "seconds": 0]]
        ])
        
        let strategy = try decoder.decode(ExecutionStrategy.self, from: data)
        let expectedStrategy = ExecutionStrategy(.once(.at(15, 30)))
        
        XCTAssertEqual(strategy, expectedStrategy)
    }
    
    func testDecodeRepeatableExecutionStrategyFromJson() throws {
        let data = try JSONSerialization.data(withJSONObject: [
            "type" : 1,
            "interval" : 60,
            "time" : [["hours": 15, "minutes": 30, "seconds": 0]]
        ])
        
        let strategy = try decoder.decode(ExecutionStrategy.self, from: data)
        let expectedStrategy = ExecutionStrategy(.repeatable(.at(15, 30), 60))
        
        XCTAssertEqual(strategy, expectedStrategy)
    }
    
    func testDecodeDaysOfWeekExecutionStrategyFromJson() throws {
        let data = try JSONSerialization.data(withJSONObject: [
            "type" : 2,
            "days" : [2, 4, 6],
            "time" : [["hours": 15, "minutes": 30, "seconds": 0]]
        ])
        
        let strategy = try decoder.decode(ExecutionStrategy.self, from: data)
        let expectedStrategy = ExecutionStrategy(.daysOfWeek([2, 4, 6], [.at(15, 30)]))
        
        XCTAssertEqual(strategy, expectedStrategy)
    }
    
    func testDecodeDaysOfMonthExecutionStrategyFromJson() throws {
        let data = try JSONSerialization.data(withJSONObject: [
            "type" : 3,
            "dates" : [1, 10, 20],
            "time" : [["hours": 15, "minutes": 30, "seconds": 0]]
        ])
        
        let strategy = try decoder.decode(ExecutionStrategy.self, from: data)
        let expectedStrategy = ExecutionStrategy(.daysOfMonth([1, 10, 20], [.at(15, 30)]))
        
        XCTAssertEqual(strategy, expectedStrategy)
    }
}

