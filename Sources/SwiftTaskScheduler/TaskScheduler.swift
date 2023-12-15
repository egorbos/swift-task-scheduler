import Foundation

/// Task scheduler which containing the tasks assigned to it.
public final class TaskScheduler {
    
    private let lock: NSLock
    
    private static let _default = TaskScheduler()
    
    /// If `true`, this task scheduler has been invalidated.
    private var invalidated: Bool
    
    private var tasks: [UUID: JobTask]
    
    /// The default singleton instance.
    public class var `default`: TaskScheduler {
        return _default
    }
    
    public init() {
        self.tasks = [:]
        self.lock = .init()
        self.invalidated = false
    }
    
    internal func addTask(_ task: JobTask) {
        tasks[task.id] = task
    }
    
    /// Returns task with a specified identifier if exists, otherwise nil.
    ///
    ///  - Parameter id: Unique identifier of task.
    public func getTask(id: UUID) -> JobTask? {
        return tasks[id]
    }
    
    /// Returns tasks with a specified tag if exists, otherwise empty array.
    ///
    ///  - Parameter tag: Tag assigned to the task.
    public func getTasks(tag: String) -> [JobTask] {
        return tasks.values.filter { $0.tag == tag }
    }
    
    internal func removeTask(by id: UUID) {
        tasks.removeValue(forKey: id)
    }
    
    /// Cancel tasks execution and remove them.
    public func invalidate() {
        guard self.lock.withLock({
            guard !self.invalidated else {
                return false
            }
            
            self.invalidated = true
            return true
        }) else {
            return
        }

        for task in self.tasks.values {
            task.destroy()
        }
    }
    
    deinit {
        assert(self.lock.withLock { self.invalidated }, "TaskScheduler.invalidate() was not called before deinit.")
    }
    
    // MARK: ONCE
    
    /// Creates a task with 'once' execution strategy type.
    ///
    ///  - Parameters:
    ///      - time: Time at which the task will be started execution.
    ///      - tag: Tag that will be assigned to the created task.
    ///      - action: The action that will be performed by the task.
    ///
    ///  - Returns: A task that will be executed once.
    @discardableResult
    public func once(_ time: ExecutionTime, tag: String = "", action: @escaping (JobTask) -> Void) -> JobTask {
        return JobTask(tag: tag, scheduler: self, strategy: .init(.once(time)), action: action)
    }
    
    /// Creates a task with 'once' execution strategy type.
    ///
    ///  - Parameters:
    ///      - time: Time at which the task will be started execution.
    ///      - tag: Tag that will be assigned to the created task.
    ///      - action: The action that will be performed by the task.
    ///
    ///  - Returns: A task that will be executed once.
    @discardableResult
    public func once(_ time: ExecutionTime, tag: String = "", action: @escaping () -> Void) -> JobTask {
        return JobTask(tag: tag, scheduler: self, strategy: .init(.once(time)), action: { (_) in action() })
    }
    
    // MARK: REPEATABLE

    /// Creates a task with 'repeatable' execution strategy type.
    ///
    ///  - Parameters:
    ///      - time: Time at which the task will be started execution.
    ///      - repeatEvery: The time interval after which the task execution will be repeated.
    ///      - tag: Tag that will be assigned to the created task.
    ///      - action: The action that will be performed by the task.
    ///
    ///  - Returns: A task that will be executed at a specified time interval.
    @discardableResult
    public func start(_ time: ExecutionTime, repeatEvery: TimeInterval, tag: String = "", action: @escaping (JobTask) -> Void) -> JobTask {
        return JobTask(tag: tag, scheduler: self, strategy: .init(.repeatable(time, repeatEvery)), action: action)
    }
    
    /// Creates a task with 'repeatable' execution strategy type.
    ///
    ///  - Parameters:
    ///      - time: Time at which the task will be started execution.
    ///      - repeatEvery: The time interval after which the task execution will be repeated.
    ///      - tag: Tag that will be assigned to the created task.
    ///      - action: The action that will be performed by the task.
    ///
    ///  - Returns: A task that will be executed at a specified time interval.
    @discardableResult
    public func start(_ time: ExecutionTime, repeatEvery: TimeInterval, tag: String = "", action: @escaping () -> Void) -> JobTask {
        return JobTask(tag: tag, scheduler: self, strategy: .init(.repeatable(time, repeatEvery)), action: { (_) in action() })
    }
    
    /// Creates a task with 'repeatable' execution strategy type.
    ///
    ///  - Parameters:
    ///      - after: The time interval after which the task will be started  execution.
    ///      - repeatEvery: The time interval after which the task execution will be repeated.
    ///      - tag: Tag that will be assigned to the created task.
    ///      - action: The action that will be performed by the task.
    ///
    ///  - Returns: A task that will be executed at a specified time interval.
    @discardableResult
    public func start(after: TimeInterval, repeatEvery: TimeInterval, tag: String = "", action: @escaping (JobTask) -> Void) -> JobTask {
        return JobTask(tag: tag, scheduler: self, strategy: .init(.repeatable(.after(after), repeatEvery)), action: action)
    }
    
    /// Creates a task with 'repeatable' execution strategy type.
    ///
    ///  - Parameters:
    ///      - after: The time interval after which the task will be started  execution.
    ///      - repeatEvery: The time interval after which the task execution will be repeated.
    ///      - tag: Tag that will be assigned to the created task.
    ///      - action: The action that will be performed by the task.
    ///
    ///  - Returns: A task that will be executed at a specified time interval.
    @discardableResult
    public func start(after: TimeInterval, repeatEvery: TimeInterval, tag: String = "", action: @escaping () -> Void) -> JobTask {
        return JobTask(tag: tag, scheduler: self, strategy: .init(.repeatable(.after(after), repeatEvery)), action: { (_) in action() })
    }
    
    // MARK: EVERYDAY
    
    /// Creates a task with 'daysOfWeek' execution strategy type, that will be executed everyday
    /// at specified time.
    ///
    ///  - Parameters:
    ///      - time: Time at which the task will be executed.
    ///      - tag: Tag that will be assigned to the created task.
    ///      - action: The action that will be performed by the task.
    ///
    ///  - Returns: A task that will be executed everyday.
    @discardableResult
    public func everyday(time: ExecutionTime..., tag: String = "", action: @escaping (JobTask) -> Void) -> JobTask {
        return every(days: ExecutionDay.allCases, time: time, tag: tag, action: action)
    }
    
    /// Creates a task with 'daysOfWeek' execution strategy type, that will be executed everyday
    /// at specified time.
    ///
    ///  - Parameters:
    ///      - time: Time at which the task will be executed.
    ///      - tag: Tag that will be assigned to the created task.
    ///      - action: The action that will be performed by the task.
    ///
    ///  - Returns: A task that will be executed everyday.
    @discardableResult
    public func everyday(time: ExecutionTime..., tag: String = "", action: @escaping () -> Void) -> JobTask {
        return every(days: ExecutionDay.allCases, time: time, tag: tag, action: { (_) in action() })
    }
    
    // MARK: WEEKENDS
    
    /// Creates a task with 'daysOfWeek' execution strategy type, that will be executed on weekends
    /// at specified time.
    ///
    ///  - Parameters:
    ///      - time: Time at which the task will be executed.
    ///      - tag: Tag that will be assigned to the created task.
    ///      - action: The action that will be performed by the task.
    ///
    ///  - Returns: A task that will be executed on weekends.
    @discardableResult
    public func weekends(time: ExecutionTime..., tag: String = "", action: @escaping (JobTask) -> Void) -> JobTask {
        let weekends: [ExecutionDay] = [.sunday, .saturday]
        return JobTask(tag: tag, scheduler: self, strategy: .init(.daysOfWeek(weekends.map { $0.rawValue }, time)), action: action)
    }
    
    /// Creates a task with 'daysOfWeek' execution strategy type, that will be executed on weekends
    /// at specified time.
    ///
    ///  - Parameters:
    ///      - time: Time at which the task will be executed.
    ///      - tag: Tag that will be assigned to the created task.
    ///      - action: The action that will be performed by the task.
    ///
    ///  - Returns: A task that will be executed on weekends.
    @discardableResult
    public func weekends(time: ExecutionTime..., tag: String = "", action: @escaping () -> Void) -> JobTask {
        let weekends: [ExecutionDay] = [.sunday, .saturday]
        return JobTask(tag: tag, scheduler: self, strategy: .init(.daysOfWeek(weekends.map { $0.rawValue }, time)), action: { (_) in action() })
    }
    
    // MARK: WEEKDAYS
    
    /// Creates a task with 'daysOfWeek' execution strategy type, that will be executed
    /// on specified days of the week and time.
    ///
    ///  - Parameters:
    ///      - days: Days of the week at which the task will be executed.
    ///      - time: Time at which the task will be executed.
    ///      - tag: Tag that will be assigned to the created task.
    ///      - action: The action that will be performed by the task.
    ///
    ///  - Returns: A task that will be executed on specified days of the week.
    @discardableResult
    public func every(_ days: ExecutionDay..., time: ExecutionTime..., tag: String = "", action: @escaping (JobTask) -> Void) -> JobTask {
        return every(days: days, time: time, tag: tag, action: action)
    }
    
    /// Creates a task with 'daysOfWeek' execution strategy type, that will be executed
    /// on specified days of the week and time.
    ///
    ///  - Parameters:
    ///      - days: Days of the week at which the task will be executed.
    ///      - time: Time at which the task will be executed.
    ///      - tag: Tag that will be assigned to the created task.
    ///      - action: The action that will be performed by the task.
    ///
    ///  - Returns: A task that will be executed on specified days of the week.
    @discardableResult
    public func every(_ days: ExecutionDay..., time: ExecutionTime..., tag: String = "", action: @escaping () -> Void) -> JobTask {
        return every(days: days, time: time, tag: tag, action: { (_) in action() })
    }
    
    private func every(days: [ExecutionDay], time: [ExecutionTime] = [.midnight], tag: String = "", action: @escaping (JobTask) -> Void) -> JobTask {
        return JobTask(tag: tag, scheduler: self, strategy: .init(.daysOfWeek(days.map { $0.rawValue }, time)), action: action)
    }
    
    // MARK: DATES
    
    /// Creates a task with 'daysOfMonth' execution strategy type, that will be executed
    /// on specified days of the month and time.
    ///
    ///  - Parameters:
    ///      - days: Days of the month at which the task will be executed.
    ///      - time: Time at which the task will be executed.
    ///      - tag: Tag that will be assigned to the created task.
    ///      - action: The action that will be performed by the task.
    ///
    ///  - Returns: A task that will be executed on specified days of the month.
    @discardableResult
    public func every(_ dates: Int..., time: ExecutionTime..., tag: String = "", action: @escaping (JobTask) -> Void) -> JobTask {
        return every(dates: dates, time: time, tag: tag, action: action)
    }
    
    /// Creates a task with 'daysOfMonth' execution strategy type, that will be executed
    /// on specified days of the month and time.
    ///
    ///  - Parameters:
    ///      - days: Days of the month at which the task will be executed.
    ///      - time: Time at which the task will be executed.
    ///      - tag: Tag that will be assigned to the created task.
    ///      - action: The action that will be performed by the task.
    ///
    ///  - Returns: A task that will be executed on specified days of the month.
    @discardableResult
    public func every(_ dates: Int..., time: ExecutionTime..., tag: String = "", action: @escaping () -> Void) -> JobTask {
        return every(dates: dates, time: time, tag: tag, action: { (_) in action() })
    }
    
    private func every(dates: [Int], time: [ExecutionTime] = [.midnight], tag: String = "", action: @escaping (JobTask) -> Void) -> JobTask {
        return JobTask(tag: tag, scheduler: self, strategy: .init(.daysOfMonth(dates, time)), action: action)
    }
}
