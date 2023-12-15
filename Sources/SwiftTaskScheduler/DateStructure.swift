import Foundation

internal struct DateStructure {
    let year: Int
    
    let month: Int
    
    let day: Int
    
    let weekday: Int
    
    let hours: Int
    
    let minutes: Int
    
    let seconds: Int
}

internal extension DateStructure {
    func with(hours: Int, minutes: Int, seconds: Int) -> DateStructure {
        DateStructure(
            year: self.year, month: self.month, day: self.day, weekday: self.weekday,
            hours: hours, minutes: minutes, seconds: seconds
        )
    }
    
    func isInclude(time: ExecutionTime) -> Bool {
        return time.hours - self.hours > 0 || (time.hours - self.hours == 0 && time.minutes - self.minutes > 0)
        || (time.hours - self.hours == 0 && time.minutes - self.minutes == 0 && time.seconds - self.seconds > 0)
    }
}

internal extension DateStructure {
    func asDate(_ calendar: Calendar) -> Date {
        calendar.date(
            from: .init(
                calendar: calendar, timeZone: calendar.timeZone,
                year: self.year, month: self.month, day: self.day,
                hour: self.hours, minute: self.minutes, second: self.seconds
            )
        )!
    }
}
