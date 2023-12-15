import Dispatch
import Foundation

/// A task to perform actions according to the schedule, established by the execution strategy.
public final class JobTask {
    public enum State: Int, Codable {
        case working
        case suspended
        case completed
        case destroyed
    }
    
    public enum Error: Swift.Error {
        case resumeDestroyedTask
    }
    
    /// Unique identifier.
    public let id: UUID
    
    /// Tag (can be assigned to a group of tasks).
    public let tag: String
    
    /// Task execution state.
    public private(set) var state: State
    
    /// Next execution date, if the status is not equals completed, otherwise nil.
    public private(set) var nextExecutionDate: Date?
    
    /// Task execution strategy.
    public private(set) var strategy: ExecutionStrategy
    
    private let action: (JobTask) -> Void
    
    private let timer: DispatchSourceTimer
    
    private let calendar: Calendar
    
    private var calculator: ExecutionDateCalculator
    
    private var scheduler: TaskScheduler?
    
    /// Creates a new `JobTask`.
    ///
    /// - Parameters:
    ///     - id: Unique task identifier in UUID format. Defaults to generated UUID value.
    ///     - tag: A tag for combining several tasks into a single semantic group. Defaults to empty string.
    ///     - scheduler: Scheduler for storing and managing tasks.
    ///     - state: Initial task state. Defaults `working`.
    ///     - queue: The queue on which the task will be executed.
    ///     - strategy: Execution strategy of task.
    ///     - action: Action that will be performing when task is running.
    public init(
        id: UUID = UUID(),
        tag: String = "",
        scheduler: TaskScheduler,
        state: State = .working,
        queue: DispatchQueue = .global(qos: .default),
        strategy: ExecutionStrategy,
        action: @escaping (JobTask) -> Void
    ) {
        self.id = id
        self.tag = tag
        self.state = state
        self.action = action
        self.strategy = strategy
        self.scheduler = scheduler
        self.calendar = .init(identifier: .gregorian)
        self.timer = DispatchSource.makeTimerSource(queue: queue)
        self.calculator = ExecutionDateCalculator(for: strategy, calendar: self.calendar)
        
        self.timer.setEventHandler { [weak self] in
            guard let me = self else { return }
            me.timerFireAction()
        }
        
        if self.state == .working {
            self.scheduleNextTimerFire()
            self.timer.resume()
        }
        
        self.scheduler!.addTask(self)
    }
    
    private func timerFireAction() {
        if strategy.type == .once {
            complete()
        } else {
            scheduleNextTimerFire()
        }
        action(self)
    }
    
    private func scheduleNextTimerFire() {
        nextExecutionDate = calculator.nextExecutionDate()
        timer.schedule(deadline: .now() + nextExecutionDate!.timeIntervalSince(Date()))
    }
    
    private func needRescheduleTimerFire() -> Bool {
        guard let nextExecutionDate = self.nextExecutionDate else {
            return true
        }
        let now = Date().asDateStructure(calendar)
        let executionTime = nextExecutionDate.time
        let dateContains = strategy.type == .daysOfMonth ? strategy.daysOfMonth.contains(now.day) : true
        let weekdayContains = strategy.type == .daysOfWeek ? strategy.daysOfWeek.contains(now.weekday) : true
        
        return !(dateContains && weekdayContains && now.isInclude(time: executionTime))
    }
    
    /// Change current execution strategy to new.
    ///
    ///  - Parameter strategy: New execution strategy.
    public func setNewExecutionStrategy(_ strategy: ExecutionStrategy) {
        self.strategy = strategy
        self.calculator = ExecutionDateCalculator(for: self.strategy, calendar: self.calendar)
        scheduleNextTimerFire()
    }
    
    private func complete() {
        timer.suspend()
        state = .completed
        nextExecutionDate = nil
    }
    
    /// Suspend a task execution.
    public func suspend() {
        if state == .suspended { return }
        state = .suspended
        timer.suspend()
    }
    
    /// Resume a task execution.
    ///
    /// Throws: Self.Error.resumeDestroyedTask - if task is destroyed.
    public func resume() throws {
        switch state {
        case .destroyed:
            throw Self.Error.resumeDestroyedTask
        case .working:
            return
        case .suspended, .completed:
            if needRescheduleTimerFire() {
                scheduleNextTimerFire()
            }
            state = .working
            timer.resume()
        }
    }
    
    /// Cancel a task execution, and remove current task from scheduler.
    public func destroy() {
        if state == .destroyed { return }
        timer.cancel()
        if let scheduler = self.scheduler {
            scheduler.removeTask(by: id)
            self.scheduler = nil
        }
        state = .destroyed
    }
}
