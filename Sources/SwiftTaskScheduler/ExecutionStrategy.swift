import Foundation

public struct ExecutionStrategy {
    
    public enum ExecutionStrategyType: String, CaseIterable {
        case once
        case repeatable
        case weekdays
        case dates
        case months
    }
    
    internal enum Wrapped {
        case once(ExecutionTime)
        case repeatable(ExecutionTime, TimeInterval)
        case weekdays([ExecutionDay], [ExecutionTime])
        case dates([Int], [ExecutionTime])
    }

    private let wrapped: Wrapped
    
    private var time: [ExecutionTime] = []
    private(set) var timeIterator: any ArrayIterator<ExecutionTime>
    
    private(set) var weekdays: [Int] = []
    private(set) var weekdaysIterator: any ArrayIterator<Int>
    
    private(set) var dates: [Int] = []
    private(set) var datesIterator: any ArrayIterator<Int>
    
    private(set) var repeatInterval: TimeInterval = 0
    
    init(_ wrapped: Wrapped) {
        self.wrapped = wrapped
        
        switch wrapped {
        case .once(let time):
            self.time = [time]
            
        case .repeatable(let time, let interval):
            self.time = [time]
            self.repeatInterval = interval
            
        case .weekdays(let days, let time):
            self.time = time.sorted()
            self.weekdays = days.map { $0.rawValue }.unique { $0 }.sorted()
            
        case .dates(let dates, let time):
            self.time = time.sorted()
            self.dates = dates.unique { $0 }.sorted()
            
        default:
            self.time = []
            self.dates = []
            self.weekdays = []
            self.repeatInterval = 0
        }
        
        self.timeIterator = self.time.makeArrayIterator()
        self.datesIterator = self.dates.makeArrayIterator()
        self.weekdaysIterator = self.weekdays.makeArrayIterator()
    }
    
    public var type: ExecutionStrategyType {
        switch wrapped {
        case .once:       return .once
        case .repeatable: return .repeatable
        case .weekdays:   return .weekdays
        case .dates:      return .dates
        default:          return .once
        }
    }
}
