import Foundation

public final class JobTask {
    
    public enum JobTaskState {
        case working
        case suspended
    }
    
    public let id: String
    
    public private(set) var state: JobTaskState
    
    public private(set) var nextExecutionDate: Date?
    
    public private(set) var strategy: ExecutionStrategy
    
    private let action: (JobTask) -> Void
    
    private let timer: DispatchSourceTimer
    
    private let calculator: ExecutionDateCalculator
    
    private weak var scheduler: TaskScheduler?
    
    internal init(
        scheduler: TaskScheduler,
        queue: DispatchQueue = .global(qos: .default),
        strategy: ExecutionStrategy,
        action: @escaping (JobTask) -> Void
    ) {
        self.action = action
        self.id = UUID().uuidString
        self.state = .suspended
        self.strategy = strategy
        self.timer = DispatchSource.makeTimerSource(queue: queue)
        self.calculator = ExecutionDateCalculator(for: strategy)
        
        timer.setEventHandler { [weak self] in
            guard let me = self else { return }
            me.timerFireAction()
        }
        
        scheduleNextTimerFire()
        
        timer.resume()
        
        scheduler.addTask(self)
    }
    
    private func timerFireAction() {
        if strategy.type == .once {
            suspend()
            nextExecutionDate = nil
        } else {
            scheduleNextTimerFire()
        }
        action(self)
    }
    
    private func scheduleNextTimerFire() {
        nextExecutionDate = calculator.nextExecutionDate()
        timer.schedule(deadline: .now() + nextExecutionDate!.timeIntervalSince(Date()))
    }
    
    // MARK: ONCE
    
    public static func once(_ time: ExecutionTime, action: @escaping (JobTask) -> Void) -> JobTask {
        return JobTask(scheduler: .default, strategy: .init(.once(time)), action: action)
    }
    
    public static func once(_ time: ExecutionTime, action: @escaping () -> Void) -> JobTask {
        return JobTask(scheduler: .default, strategy: .init(.once(time)), action: { (_) in action() })
    }
    
    // MARK: REPEATABLE
    
    public static func start(_ time: ExecutionTime, repeatEvery: TimeInterval, action: @escaping (JobTask) -> Void) -> JobTask {
        return JobTask(scheduler: .default, strategy: .init(.repeatable(time, repeatEvery)), action: action)
    }
    
    public static func start(_ time: ExecutionTime, repeatEvery: TimeInterval, action: @escaping () -> Void) -> JobTask {
        return JobTask(scheduler: .default, strategy: .init(.repeatable(time, repeatEvery)), action: { (_) in action() })
    }
    
    // MARK: EVERYDAY
    
    public static func everyday(time: ExecutionTime..., action: @escaping (JobTask) -> Void) -> JobTask {
        return JobTask.every(days: ExecutionDay.allCases, time: time, action: action)
    }
    
    public static func everyday(time: ExecutionTime..., action: @escaping () -> Void) -> JobTask {
        return JobTask.every(days: ExecutionDay.allCases, time: time, action: { (_) in action() })
    }
    
    // MARK: WEEKENDS
    
    public static func weekends(time: ExecutionTime..., action: @escaping (JobTask) -> Void) -> JobTask {
        return JobTask(scheduler: .default, strategy: .init(.weekdays([.sunday, .saturday], time)), action: action)
    }
    
    public static func weekends(time: ExecutionTime..., action: @escaping () -> Void) -> JobTask {
        return JobTask(scheduler: .default, strategy: .init(.weekdays([.sunday, .saturday], time)), action: { (_) in action() })
    }
    
    // MARK: WEEKDAYS
    
    public static func every(_ days: ExecutionDay..., time: ExecutionTime..., action: @escaping (JobTask) -> Void) -> JobTask {
        return JobTask.every(days: days, time: time, action: action)
    }
    
    public static func every(_ days: ExecutionDay..., time: ExecutionTime..., action: @escaping () -> Void) -> JobTask {
        return JobTask.every(days: days, time: time, action: { (_) in action() })
    }
    
    private static func every(days: [ExecutionDay], time: [ExecutionTime] = [.midnight], action: @escaping (JobTask) -> Void) -> JobTask {
        return JobTask(scheduler: .default, strategy: .init(.weekdays(days, time)), action: action)
    }
    
    // MARK: DATES
    
    public static func every(_ dates: Int..., time: ExecutionTime..., action: @escaping (JobTask) -> Void) -> JobTask {
        return JobTask.every(dates: dates, time: time, action: action)
    }
    
    public static func every(_ dates: Int..., time: ExecutionTime..., action: @escaping () -> Void) -> JobTask {
        return JobTask.every(dates: dates, time: time, action: { (_) in action() })
    }
    
    private static func every(dates: [Int], time: [ExecutionTime] = [.midnight], action: @escaping (JobTask) -> Void) -> JobTask {
        return JobTask(scheduler: .default, strategy: .init(.dates(dates, time)), action: action)
    }
    
    // start?
    // set task scheduler!
    
    public func resume() {
        if state == .working {
            return
        }
        // check strategy, remove task if not actual?
        // or check next execution date
        // get new, and reschedule timer
        state = .working
        timer.resume()
    }
    
    public func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
}
