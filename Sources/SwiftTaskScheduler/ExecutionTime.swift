public final class ExecutionTime {
    internal let hours: Int
    
    internal let minutes: Int
    
    internal let seconds: Int
    
    private init(hours: Int, minutes: Int, seconds: Int) {
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
    }
    
    public static var midnight: ExecutionTime { .at(0, 0, 0) }
    
    public static var noon: ExecutionTime { .at(12, 0, 0) }
    
    public static func at(_ hours: Int, _ minutes: Int = 0, _ seconds: Int = 0) -> ExecutionTime {
        return ExecutionTime(hours: hours, minutes: minutes, seconds: seconds)
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
