import Foundation

internal final class ExecutionDateCalculator {
    
    private var calendar: Calendar
        
    private var prevExecutionDate: Date?
    
    private let strategy: ExecutionStrategy
    
    init(for strategy: ExecutionStrategy, withTimezone timezone: TimeZone = .current) {
        self.calendar = .init(identifier: .gregorian)
        self.calendar.timeZone = timezone
        self.strategy = strategy
    }
    
    func nextExecutionDate() -> Date {
        // check (convert) 12(am,pm)/24 format
        let now = Date().asDateStructure(calendar)
        let nextExecutionDate = switch strategy.type {
        case .once: onlyOnceExecutionDate(now)
        case .repeatable: repeatableExecutionDate(now)
        case .weekdays: weekdaysExecutionDate(now)
        case .dates: datesExecutionDate(now)
        default: onlyOnceExecutionDate(now)
        }
        prevExecutionDate = nextExecutionDate
        return nextExecutionDate
    }
    
    private func isExecutionToday(_ now: DateStructure, useDate: Bool = false, useWeekday: Bool = false) -> Bool {
        let dateContains = useDate ? strategy.dates.contains(now.day) : true
        let weekdayContains = useWeekday ? strategy.weekdays.contains(now.weekday) : true
        
        while strategy.timeIterator.hasNext {
            let time = strategy.timeIterator.next()
            if dateContains && weekdayContains && now.isTimeInDate(time) {
                return true
            }
        }
        
        return false
    }
    
    private func onlyOnceExecutionDate(_ now: DateStructure) -> Date {
        let todayExecution = isExecutionToday(now)
        let time = strategy.timeIterator.current!
        let nextDate = now.with(hours: time.hours, minutes: time.minutes, seconds: time.seconds)
            .asDate(calendar)
        strategy.timeIterator.drop()
        return todayExecution ? nextDate : nextDate.addingTimeInterval(1.days)
    }
    
    private func repeatableExecutionDate(_ now: DateStructure) -> Date {
        if let prevDate = prevExecutionDate {
            return prevDate.addingTimeInterval(strategy.repeatInterval)
        }
        return onlyOnceExecutionDate(now)
    }
    
    private func calcWeekdaysDistance(from: Int, to: Int) -> Int {
        return 7 - (from - to)
    }
    
    private func newWeekdaysExecutionDate(now: DateStructure) -> Date {
        while strategy.weekdaysIterator.hasNext {
            let weekday = strategy.weekdaysIterator.next()
            if weekday > now.weekday && strategy.timeIterator.hasNext {
                let time = strategy.timeIterator.next()
                return now.with(hours: time.hours, minutes: time.minutes, seconds: time.seconds)
                    .asDate(calendar)
                    .addingTimeInterval((weekday - now.weekday).days)
            }
        }
        
        strategy.weekdaysIterator.drop()
        
        let weekday = strategy.weekdaysIterator.next()
        let time = strategy.timeIterator.next()
        let adding = calcWeekdaysDistance(from: now.weekday, to: weekday)
        return now.with(hours: time.hours, minutes: time.minutes, seconds: time.seconds)
            .asDate(calendar)
            .addingTimeInterval(adding.days)
    }
    
    private func weekdaysExecutionDate(_ now: DateStructure) -> Date {
        let todayExecution = isExecutionToday(now, useWeekday: true)
        
        if todayExecution {
            let time = strategy.timeIterator.current!
            let nextDate = now.with(hours: time.hours, minutes: time.minutes, seconds: time.seconds)
                .asDate(calendar)
            return nextDate
        }
        
        strategy.timeIterator.drop()
        return newWeekdaysExecutionDate(now: now)
    }
    
    private func calcDatesDistance(from: Int, to: Int, daysInMonth: Int) -> Int {
        return daysInMonth - from + to
    }
    
    private func newDatesExecutionDate(now: DateStructure) -> Date {
        let daysInMonth = calendar.range(of: .day, in: .month, for: now.asDate(calendar))!
        
        while strategy.datesIterator.hasNext {
            let date = strategy.datesIterator.next()
            if date > now.day && daysInMonth.contains(date) && strategy.timeIterator.hasNext {
                let time = strategy.timeIterator.next()
                return now.with(hours: time.hours, minutes: time.minutes, seconds: time.seconds)
                    .asDate(calendar)
                    .addingTimeInterval((date - now.day).days)
            }
        }
        
        strategy.datesIterator.drop()
        
        let date = strategy.datesIterator.next()
        let time = strategy.timeIterator.next()
        let adding = calcDatesDistance(from: now.day, to: date, daysInMonth: daysInMonth.count)
        return now.with(hours: time.hours, minutes: time.minutes, seconds: time.seconds)
            .asDate(calendar)
            .addingTimeInterval(adding.days)
    }
    
    private func datesExecutionDate(_ now: DateStructure) -> Date {
        let todayExecution = isExecutionToday(now, useDate: true)
        
        if todayExecution {
            let time = strategy.timeIterator.current!
            let nextDate = now.with(hours: time.hours, minutes: time.minutes, seconds: time.seconds)
                .asDate(calendar)
            return nextDate
        }
        
        strategy.timeIterator.drop()
        return newDatesExecutionDate(now: now)
    }
}
