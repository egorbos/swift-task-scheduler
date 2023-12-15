import XCTest
@testable import SwiftTaskScheduler

final class JobTaskTests: XCTestCase {
    func testExecutionStrategyOfNewJob() {
        let task = JobTask(scheduler: TaskScheduler.default, strategy: .init(.once(.after(1.days)))) { _ in }
        XCTAssertEqual(task.strategy.type, .once)
    }

    func testSetNewExecutionStrategy() {
        let task = JobTask(scheduler: TaskScheduler.default, strategy: .init(.once(.after(1.days)))) { _ in }
        task.setNewExecutionStrategy(.init(.repeatable(.midnight, 1.hours)))
        XCTAssertEqual(task.strategy.type, .repeatable)
    }
    
    func testSuspendTask() {
        let task = JobTask(scheduler: TaskScheduler.default, strategy: .init(.once(.after(1.days)))) { _ in }
        task.suspend()
        XCTAssertEqual(task.state, .suspended)
    }
    
    func testResumeTask() throws {
        let task = JobTask(scheduler: TaskScheduler.default, strategy: .init(.once(.after(1.days)))) { _ in }
        task.suspend()
        try task.resume()
        XCTAssertEqual(task.state, .working)
    }
    
    func testCompletedStatusAfterOnceExecutionStrategyTaskIsDone() {
        let expect = expectation(description: "Working")

        let task = JobTask(scheduler: TaskScheduler.default, strategy: .init(.once(.after(1.seconds)))) { _ in
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 3.seconds, handler: nil)
        
        XCTAssertEqual(task.state, .completed)
    }
    
    func testThrowingErrorWhenTryResumeDestroyedTask() {
        let task = JobTask(scheduler: TaskScheduler.default, strategy: .init(.once(.after(1.days)))) { _ in }
        task.destroy()
        XCTAssertThrowsError(try task.resume()) { error in
            XCTAssertEqual(error as! JobTask.Error, JobTask.Error.resumeDestroyedTask)
        }
    }
}

