import Foundation

/// Represents the time at which the task is scheduled to run.
public struct ExecutionTime: Codable {
    /// The hours component of the time.
    public let hours: Int
    
    /// The minutes component of the time.
    public let minutes: Int
    
    /// The seconds component of the time.
    public let seconds: Int
    
    internal init(hours: Int, minutes: Int, seconds: Int) {
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
    }
    
    /// Returns an instance of the `ExecutionTime`, that represents 00:00:00 time.
    public static let midnight: ExecutionTime = .init(hours: 0, minutes: 0, seconds: 0)
    
    /// Returns an instance of the `ExecutionTime`, that represents 12:00:00 time.
    public static let noon: ExecutionTime = .init(hours: 12, minutes: 0, seconds: 0)
    
    /// Returns an instance of the `ExecutionTime` for planning task execution.
    ///
    ///  - Parameters:
    ///      - hours: The hours component of the time.
    ///      - minutes: The minutes component of the time.
    ///      - seconds: The seconds component of the time.
    public static func at(_ hours: Int, _ minutes: Int = 0, _ seconds: Int = 0) -> ExecutionTime {
        return ExecutionTime(hours: hours, minutes: minutes, seconds: seconds)
    }
    
    /// Returns an instance of the `ExecutionTime` for planning task execution.
    ///
    ///  - Parameter interval: The time interval after which the task execution will be started.
    public static func after(_ interval: TimeInterval) -> ExecutionTime {
        return Date().addingTimeInterval(interval).time
    }
}

extension ExecutionTime: Comparable {
    public static func < (lhs: ExecutionTime, rhs: ExecutionTime) -> Bool {
        return lhs.hours < rhs.hours || (lhs.hours == rhs.hours && lhs.minutes < rhs.minutes)
        || (lhs.hours == rhs.hours && lhs.minutes == rhs.minutes && lhs.seconds < rhs.seconds)
    }
    
    public static func == (lhs: ExecutionTime, rhs: ExecutionTime) -> Bool {
        return lhs.hours == rhs.hours && lhs.minutes == rhs.minutes && lhs.seconds == rhs.seconds
    }
}

extension Date {
    var time: ExecutionTime {
        let date = self.asDateStructure(.current)
        return ExecutionTime(hours: date.hours, minutes: date.minutes, seconds: date.seconds)
    }
}
