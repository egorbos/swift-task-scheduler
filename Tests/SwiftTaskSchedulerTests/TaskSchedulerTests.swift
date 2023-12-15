import XCTest
@testable import SwiftTaskScheduler

final class TaskSchedulerTests: XCTestCase {
    
    var scheduler: TaskScheduler!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        self.scheduler = TaskScheduler()
    }
    
    override func tearDownWithError() throws {
        self.scheduler.invalidate()
        self.scheduler = nil
        try super.tearDownWithError()
    }
    
    func testGetTaskById() {
        let task = JobTask(scheduler: self.scheduler, strategy: .init(.once(.after(1.days)))) { _ in }
        XCTAssertNotNil(self.scheduler.getTask(id: task.id))
    }
    
    func testGetTasksByTag() {
        _ = JobTask(tag: "test", scheduler: self.scheduler, strategy: .init(.once(.after(1.days)))) { _ in }
        _ = JobTask(tag: "some-tag", scheduler: self.scheduler, strategy: .init(.once(.after(1.days)))) { _ in }
        _ = JobTask(tag: "test", scheduler: self.scheduler, strategy: .init(.once(.after(1.days)))) { _ in }
        XCTAssertEqual(self.scheduler.getTasks(tag: "test").count, 2)
        XCTAssertEqual(self.scheduler.getTasks(tag: "some-tag").count, 1)
    }
    
    func testInvalidateTaskScheduler() {
        let task = JobTask(tag: "test", scheduler: self.scheduler, strategy: .init(.once(.after(1.days)))) { _ in }
        XCTAssertNotNil(self.scheduler.getTask(id: task.id))
        
        self.scheduler.invalidate()
        
        XCTAssertEqual(task.state, .destroyed)
        XCTAssertNil(self.scheduler.getTask(id: task.id))
        XCTAssertEqual(self.scheduler.getTasks(tag: "test").count, 0)
    }
    
    // MARK: ONCE
    
    func testCreateOnceExecutionStrategyTask() {
        let task = self.scheduler.once(.midnight) { }
        XCTAssertNotNil(self.scheduler.getTask(id: task.id))
        XCTAssertEqual(task.strategy.type, .once)
        XCTAssertEqual(task.strategy.time, [.midnight])
    }
    
    // MARK: REPEATABLE
    
    func testCreateRepeatableExecutionStrategyTask() {
        let task = self.scheduler.start(.midnight, repeatEvery: 1.days) { }
        XCTAssertNotNil(self.scheduler.getTask(id: task.id))
        XCTAssertEqual(task.strategy.type, .repeatable)
        XCTAssertEqual(task.strategy.time, [.midnight])
        XCTAssertEqual(task.strategy.repeatInterval, 1.days)
    }
    
    func testCreateRepeatableExecutionStrategyStartAfterTimeIntervalTask() {
        let task = self.scheduler.start(after: 1.hours, repeatEvery: 1.days) { }
        let expectedStartTime = Date().addingTimeInterval(1.hours).time
        XCTAssertNotNil(self.scheduler.getTask(id: task.id))
        XCTAssertEqual(task.strategy.type, .repeatable)
        XCTAssertEqual(task.strategy.time, [expectedStartTime])
        XCTAssertEqual(task.strategy.repeatInterval, 1.days)
    }
    
    // MARK: EVERYDAY
    
    func testCreateEverydayExecutionStrategyTask() {
        let task = self.scheduler.everyday(time: .midnight, .noon) { }
        XCTAssertNotNil(self.scheduler.getTask(id: task.id))
        XCTAssertEqual(task.strategy.type, .daysOfWeek)
        XCTAssertEqual(task.strategy.time, [.midnight, .noon])
        XCTAssertEqual(task.strategy.daysOfWeek, [1, 2, 3, 4, 5, 6, 7])
    }
    
    // MARK: WEEKENDS
    
    func testCreateWeekendsExecutionStrategyTask() {
        let task = self.scheduler.weekends(time: .midnight) { }
        XCTAssertNotNil(self.scheduler.getTask(id: task.id))
        XCTAssertEqual(task.strategy.type, .daysOfWeek)
        XCTAssertEqual(task.strategy.time, [.midnight])
        XCTAssertEqual(task.strategy.daysOfWeek, [1, 7])
    }
    
    // MARK: WEEKDAYS
    
    func testCreateWeekDaysExecutionStrategyTask() {
        let task = self.scheduler.every(.monday, .tuesday, .thursday, time: .midnight) { }
        XCTAssertNotNil(self.scheduler.getTask(id: task.id))
        XCTAssertEqual(task.strategy.type, .daysOfWeek)
        XCTAssertEqual(task.strategy.time, [.midnight])
        XCTAssertEqual(task.strategy.daysOfWeek, [2, 3, 5])
    }
    
    // MARK: DATES
    
    func testCreateMonthDaysExecutionStrategyTask() {
        let task = self.scheduler.every(1, 15, 30, time: .at(15, 30)) { }
        XCTAssertNotNil(self.scheduler.getTask(id: task.id))
        XCTAssertEqual(task.strategy.type, .daysOfMonth)
        XCTAssertEqual(task.strategy.time, [ExecutionTime(hours: 15, minutes: 30, seconds: 0)])
        XCTAssertEqual(task.strategy.daysOfMonth, [1, 15, 30])
    }
}
