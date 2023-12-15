import XCTest
@testable import SwiftTaskScheduler

final class ExecutionDateCalculatorTests: XCTestCase {
    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return calendar
    }
    
    // 05.12.2023, Tu, 00:00:00
    let testDate = DateStructure(
        year: 2023, month: 12, day: 5, weekday: 3, hours: 0, minutes: 0, seconds: 0
    )
    
    // MARK: ONCE
    
    func testOnceExecutionStrategyCalculatedDateIsToday() {
        let strategy = ExecutionStrategy(.once(.noon)) // 12:00:00
        let executionDateCalculator = ExecutionDateCalculator(for: strategy, calendar: self.calendar)
        
        let nextExecutionDate = executionDateCalculator
            .nextExecutionDate(for: self.testDate.asDate(self.calendar))
            .asDateStructure(self.calendar)
        
        XCTAssertEqual(nextExecutionDate.year, self.testDate.year)
        XCTAssertEqual(nextExecutionDate.month, self.testDate.month)
        XCTAssertEqual(nextExecutionDate.day, self.testDate.day)
        XCTAssertEqual(nextExecutionDate.weekday, self.testDate.weekday)
        XCTAssertEqual(nextExecutionDate.hours, 12)
        XCTAssertEqual(nextExecutionDate.minutes, 0)
        XCTAssertEqual(nextExecutionDate.seconds, 0)
    }
    
    func testOnceExecutionStrategyCalculatedDateIsTomorrow() {
        let strategy = ExecutionStrategy(.once(.noon)) // 12:00:00
        let executionDateCalculator = ExecutionDateCalculator(for: strategy, calendar: self.calendar)
        
        let now = self.testDate.with(hours: 13, minutes: 0, seconds: 0)
        let nextExecutionDate = executionDateCalculator
            .nextExecutionDate(for: now.asDate(self.calendar))
            .asDateStructure(self.calendar)
        
        XCTAssertEqual(nextExecutionDate.year, now.year)
        XCTAssertEqual(nextExecutionDate.month, now.month)
        XCTAssertEqual(nextExecutionDate.day, now.day + 1)
        XCTAssertEqual(nextExecutionDate.weekday, now.weekday + 1)
        XCTAssertEqual(nextExecutionDate.hours, 12)
        XCTAssertEqual(nextExecutionDate.minutes, 0)
        XCTAssertEqual(nextExecutionDate.seconds, 0)
    }
    
    func testOnceExecutionStrategyCalculatedDateAfterTaskStarted() {
        let strategy = ExecutionStrategy(.once(.noon)) // 12:00:00
        let executionDateCalculator = ExecutionDateCalculator(for: strategy, calendar: self.calendar)
        
        _ = executionDateCalculator
            .nextExecutionDate(for: self.testDate.asDate(self.calendar))
        
        // Date after task started and do something
        let now = self.testDate.with(hours: 12, minutes: 0, seconds: 0)
        let nextExecutionDate = executionDateCalculator
            .nextExecutionDate(for: now.asDate(self.calendar))
            .asDateStructure(self.calendar)
        
        XCTAssertEqual(nextExecutionDate.year, self.testDate.year)
        XCTAssertEqual(nextExecutionDate.month, self.testDate.month)
        XCTAssertEqual(nextExecutionDate.day, self.testDate.day + 1)
        XCTAssertEqual(nextExecutionDate.weekday, self.testDate.weekday + 1)
        XCTAssertEqual(nextExecutionDate.hours, 12)
        XCTAssertEqual(nextExecutionDate.minutes, 0)
        XCTAssertEqual(nextExecutionDate.seconds, 0)
    }
    
    // MARK: REPEATABLE
    
    func testRepeatableExecutionStrategyCalculatedDateIsToday() {
        let strategy = ExecutionStrategy(.repeatable(.noon, 1.hours)) // 12:00:00
        let executionDateCalculator = ExecutionDateCalculator(for: strategy, calendar: self.calendar)
        
        let nextExecutionDate = executionDateCalculator
            .nextExecutionDate(for: self.testDate.asDate(self.calendar))
            .asDateStructure(self.calendar)
        
        XCTAssertEqual(nextExecutionDate.year, self.testDate.year)
        XCTAssertEqual(nextExecutionDate.month, self.testDate.month)
        XCTAssertEqual(nextExecutionDate.day, self.testDate.day)
        XCTAssertEqual(nextExecutionDate.weekday, self.testDate.weekday)
        XCTAssertEqual(nextExecutionDate.hours, 12)
        XCTAssertEqual(nextExecutionDate.minutes, 0)
        XCTAssertEqual(nextExecutionDate.seconds, 0)
    }
    
    func testRepeatableExecutionStrategyCalculatedDateIsTomorrow() {
        let strategy = ExecutionStrategy(.repeatable(.noon, 1.hours)) // 12:00:00
        let executionDateCalculator = ExecutionDateCalculator(for: strategy, calendar: self.calendar)
        
        let now = self.testDate.with(hours: 13, minutes: 0, seconds: 0)
        let nextExecutionDate = executionDateCalculator
            .nextExecutionDate(for: now.asDate(self.calendar))
            .asDateStructure(self.calendar)
        
        XCTAssertEqual(nextExecutionDate.year, now.year)
        XCTAssertEqual(nextExecutionDate.month, now.month)
        XCTAssertEqual(nextExecutionDate.day, now.day + 1)
        XCTAssertEqual(nextExecutionDate.weekday, now.weekday + 1)
        XCTAssertEqual(nextExecutionDate.hours, 12)
        XCTAssertEqual(nextExecutionDate.minutes, 0)
        XCTAssertEqual(nextExecutionDate.seconds, 0)
    }
    
    func testRepeatableExecutionStrategyCalculatedDateAfterTaskStarted() {
        let strategy = ExecutionStrategy(.repeatable(.noon, 1.hours)) // 12:00:00
        let executionDateCalculator = ExecutionDateCalculator(for: strategy, calendar: self.calendar)
        
        _ = executionDateCalculator
            .nextExecutionDate(for: self.testDate.asDate(self.calendar))
        
        // Date after task started and do something
        let now = self.testDate.with(hours: 12, minutes: 0, seconds: 0)
        let nextExecutionDate = executionDateCalculator
            .nextExecutionDate(for: now.asDate(self.calendar))
            .asDateStructure(self.calendar)
        
        XCTAssertEqual(nextExecutionDate.year, self.testDate.year)
        XCTAssertEqual(nextExecutionDate.month, self.testDate.month)
        XCTAssertEqual(nextExecutionDate.day, self.testDate.day)
        XCTAssertEqual(nextExecutionDate.weekday, self.testDate.weekday)
        XCTAssertEqual(nextExecutionDate.hours, 13)
        XCTAssertEqual(nextExecutionDate.minutes, 0)
        XCTAssertEqual(nextExecutionDate.seconds, 0)
    }
    
    // MARK: DAYS OF WEEK
    
    func testDaysOfWeekExecutionStrategyCalculatedDateIsToday() {
        let strategy = ExecutionStrategy(.daysOfWeek([1, 3, 5, 7], [.noon])) // Su, Tu, Th, Sa - 12:00:00
        let executionDateCalculator = ExecutionDateCalculator(for: strategy, calendar: self.calendar)
        
        let nextExecutionDate = executionDateCalculator
            .nextExecutionDate(for: self.testDate.asDate(self.calendar))
            .asDateStructure(self.calendar)
        
        XCTAssertEqual(nextExecutionDate.year, self.testDate.year)
        XCTAssertEqual(nextExecutionDate.month, self.testDate.month)
        XCTAssertEqual(nextExecutionDate.day, self.testDate.day)
        XCTAssertEqual(nextExecutionDate.weekday, self.testDate.weekday)
        XCTAssertEqual(nextExecutionDate.hours, 12)
        XCTAssertEqual(nextExecutionDate.minutes, 0)
        XCTAssertEqual(nextExecutionDate.seconds, 0)
    }
    
    func testDaysOfWeekExecutionStrategyCalculatedDateIsDayAfterTomorrowWhenTaskStarted() {
        let strategy = ExecutionStrategy(.daysOfWeek([1, 3, 5, 7], [.noon])) // Su, Tu, Th, Sa - 12:00:00
        let executionDateCalculator = ExecutionDateCalculator(for: strategy, calendar: self.calendar)
        
        _ = executionDateCalculator
            .nextExecutionDate(for: self.testDate.asDate(self.calendar))
        
        // Date after task started and do something
        let now = self.testDate.with(hours: 12, minutes: 0, seconds: 0)
        let nextExecutionDate = executionDateCalculator
            .nextExecutionDate(for: now.asDate(self.calendar))
            .asDateStructure(self.calendar)
        
        XCTAssertEqual(nextExecutionDate.year, self.testDate.year)
        XCTAssertEqual(nextExecutionDate.month, self.testDate.month)
        XCTAssertEqual(nextExecutionDate.day, self.testDate.day + 2)
        XCTAssertEqual(nextExecutionDate.weekday, 5)
        XCTAssertEqual(nextExecutionDate.hours, 12)
        XCTAssertEqual(nextExecutionDate.minutes, 0)
        XCTAssertEqual(nextExecutionDate.seconds, 0)
    }
    
    func testDaysOfWeekExecutionStrategyCheckWeekDayAndTime() {
        let strategy = ExecutionStrategy(.daysOfWeek([1], [.noon])) // Su - 12:00:00
        let executionDateCalculator = ExecutionDateCalculator(for: strategy, calendar: self.calendar)
        
        let nextExecutionDate = executionDateCalculator
            .nextExecutionDate(for: self.testDate.asDate(self.calendar))
            .asDateStructure(self.calendar)
        
        XCTAssertEqual(nextExecutionDate.year, self.testDate.year)
        XCTAssertEqual(nextExecutionDate.month, self.testDate.month)
        XCTAssertEqual(nextExecutionDate.day, self.testDate.day + 5)
        XCTAssertEqual(nextExecutionDate.weekday, 1)
        XCTAssertEqual(nextExecutionDate.hours, 12)
        XCTAssertEqual(nextExecutionDate.minutes, 0)
        XCTAssertEqual(nextExecutionDate.seconds, 0)
    }
    
    // MARK: DAYS OF MONTH
    
    func testDaysOfMonthExecutionStrategyCalculatedDateIsToday() {
        let strategy = ExecutionStrategy(.daysOfMonth([5, 10, 15], [.noon])) // 5, 10, 15 - 12:00:00
        let executionDateCalculator = ExecutionDateCalculator(for: strategy, calendar: self.calendar)
        
        let nextExecutionDate = executionDateCalculator
            .nextExecutionDate(for: self.testDate.asDate(self.calendar))
            .asDateStructure(self.calendar)
        
        XCTAssertEqual(nextExecutionDate.year, self.testDate.year)
        XCTAssertEqual(nextExecutionDate.month, self.testDate.month)
        XCTAssertEqual(nextExecutionDate.day, self.testDate.day)
        XCTAssertEqual(nextExecutionDate.weekday, self.testDate.weekday)
        XCTAssertEqual(nextExecutionDate.hours, 12)
        XCTAssertEqual(nextExecutionDate.minutes, 0)
        XCTAssertEqual(nextExecutionDate.seconds, 0)
    }
    
    func testDaysOfMonthExecutionStrategyCalculatedDateIsNextDayAfterTaskStarted() {
        let strategy = ExecutionStrategy(.daysOfMonth([5, 10, 15], [.noon])) // 5, 10, 15 - 12:00:00
        let executionDateCalculator = ExecutionDateCalculator(for: strategy, calendar: self.calendar)
        
        _ = executionDateCalculator
            .nextExecutionDate(for: self.testDate.asDate(self.calendar))
        
        // Date after task started and do something
        let now = self.testDate.with(hours: 12, minutes: 0, seconds: 0)
        let nextExecutionDate = executionDateCalculator
            .nextExecutionDate(for: now.asDate(self.calendar))
            .asDateStructure(self.calendar)
        
        XCTAssertEqual(nextExecutionDate.year, self.testDate.year)
        XCTAssertEqual(nextExecutionDate.month, self.testDate.month)
        XCTAssertEqual(nextExecutionDate.day, 10)
        XCTAssertEqual(nextExecutionDate.weekday, 1)
        XCTAssertEqual(nextExecutionDate.hours, 12)
        XCTAssertEqual(nextExecutionDate.minutes, 0)
        XCTAssertEqual(nextExecutionDate.seconds, 0)
    }
    
    func testDaysOfMonthExecutionStrategyCheckMonthDayAndTime() {
        let strategy = ExecutionStrategy(.daysOfMonth([5], [.noon])) // 5, 10, 15 - 12:00:00
        let executionDateCalculator = ExecutionDateCalculator(for: strategy, calendar: self.calendar)
        
        let now = self.testDate.with(hours: 20, minutes: 0, seconds: 0)
        let nextExecutionDate = executionDateCalculator
            .nextExecutionDate(for: now.asDate(self.calendar))
            .asDateStructure(self.calendar)
        
        XCTAssertEqual(nextExecutionDate.year, 2024)
        XCTAssertEqual(nextExecutionDate.month, 1)
        XCTAssertEqual(nextExecutionDate.day, 5)
        XCTAssertEqual(nextExecutionDate.weekday, 6)
        XCTAssertEqual(nextExecutionDate.hours, 12)
        XCTAssertEqual(nextExecutionDate.minutes, 0)
        XCTAssertEqual(nextExecutionDate.seconds, 0)
    }
}
