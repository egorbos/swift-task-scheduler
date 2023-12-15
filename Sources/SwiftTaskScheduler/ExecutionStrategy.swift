import Foundation

/// Task execution strategy, for example 'once at 12:30' or 'everyday at 11:00, 23:00'.
public struct ExecutionStrategy {
    public enum StrategyType: Int, CaseIterable, Codable {
        case once
        case repeatable
        case daysOfWeek
        case daysOfMonth
    }
    
    public enum Error: Swift.Error {
        case invalidInitializationData
    }
    
    /// Wrapped value of execution strategy.
    public enum Wrapped {
        case once(ExecutionTime)
        case repeatable(ExecutionTime, TimeInterval)
        case daysOfWeek([Int], [ExecutionTime])
        case daysOfMonth([Int], [ExecutionTime])
    }

    private let wrapped: Wrapped
    
    /// Time at which the task will be started execution.
    public private(set) var time: [ExecutionTime] = []
    private(set) var timeIterator: any ArrayIterator<ExecutionTime>
    
    /// The days of the week on which the task will be executed,
    /// if the execution strategy is weekdays.
    public private(set) var daysOfWeek: [Int] = []
    private(set) var daysOfWeekIterator: any ArrayIterator<Int>
    
    /// The days of the month on which the task will be executed,
    /// if the execution strategy is dates.
    public private(set) var daysOfMonth: [Int] = []
    private(set) var daysOfMonthIterator: any ArrayIterator<Int>
    
    /// The time interval after which the task will be executed,
    /// if the execution strategy is repeatable.
    public private(set) var repeatInterval: TimeInterval = 0
    
    /// Execution strategy type.
    public var type: StrategyType {
        switch wrapped {
        case .once: return .once
        case .repeatable: return .repeatable
        case .daysOfWeek: return .daysOfWeek
        case .daysOfMonth: return .daysOfMonth
        }
    }
    
    public init(_ wrapped: Wrapped) {
        self.wrapped = wrapped
        
        switch wrapped {
        case .once(let time):
            self.time = [time]
            
        case .repeatable(let time, let interval):
            self.time = [time]
            self.repeatInterval = interval
            
        case .daysOfWeek(let days, let time):
            self.time = time.sorted()
            self.daysOfWeek = days.unique { $0 }.sorted()
            
        case .daysOfMonth(let dates, let time):
            self.time = time.sorted()
            self.daysOfMonth = dates.unique { $0 }.sorted()
        }
        
        self.timeIterator = self.time.makeArrayIterator()
        self.daysOfMonthIterator = self.daysOfMonth.makeArrayIterator()
        self.daysOfWeekIterator = self.daysOfWeek.makeArrayIterator()
    }
}

extension ExecutionStrategy: Equatable {
    public static func == (lhs: ExecutionStrategy, rhs: ExecutionStrategy) -> Bool {
        switch (lhs.type, rhs.type) {
        case (.once, .once): return lhs.time == rhs.time
        case (.repeatable, .repeatable): return lhs.time == rhs.time && lhs.repeatInterval == rhs.repeatInterval
        case (.daysOfWeek, .daysOfWeek): return lhs.time == rhs.time && lhs.daysOfWeek == rhs.daysOfWeek
        case (.daysOfMonth, .daysOfMonth): return lhs.time == rhs.time && lhs.daysOfMonth == rhs.daysOfMonth
        default: return false
        }
    }
}

extension ExecutionStrategy: Codable {
    public enum CodingKeys: String, CodingKey {
        case type
        case time
        case days
        case dates
        case interval
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = if let decodedType = try values.decodeIfPresent(StrategyType.self, forKey: .type) {
            decodedType
        }else { StrategyType.once }
        
        let time = if let decodedTime = try values.decodeIfPresent([ExecutionTime].self, forKey: .time), !decodedTime.isEmpty {
            decodedTime
        } else { [ExecutionTime.midnight] }
        
        let days: [Int] = if let decodedDays = try values.decodeIfPresent([Int].self, forKey: .days), !decodedDays.isEmpty {
            decodedDays
        } else { [] }
        
        let dates: [Int] = if let decodedDates = try values.decodeIfPresent([Int].self, forKey: .dates), !decodedDates.isEmpty {
            decodedDates
        } else { [] }
        
        if (type == .daysOfWeek && days.isEmpty) || (type == .daysOfMonth && dates.isEmpty) {
            throw Self.Error.invalidInitializationData
        }
        
        let interval = if let decodedInterval = try values.decodeIfPresent(TimeInterval.self, forKey: .interval) {
            decodedInterval
        } else { 1.days }
        
        let wrappedValue: Wrapped = switch type {
        case .once: .once(time[0])
        case .repeatable: .repeatable(time[0], interval)
        case .daysOfWeek: .daysOfWeek(days, time)
        case .daysOfMonth: .daysOfMonth(dates, time)
        }
        
        self.init(wrappedValue)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.time, forKey: .time)
        
        if self.type == .repeatable {
            try container.encode(self.repeatInterval, forKey: .interval)
        } else if self.type == .daysOfWeek {
            try container.encode(self.daysOfWeek, forKey: .days)
        } else if self.type == .daysOfMonth {
            try container.encode(self.daysOfMonth, forKey: .dates)
        }
    }
}
