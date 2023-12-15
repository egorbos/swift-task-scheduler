import Foundation

internal class ExecutionDateCalculator {
    
    private var calendar: Calendar
        
    private var prevExecutionDate: Date?
    
    private let strategy: ExecutionStrategy
    
    init(for strategy: ExecutionStrategy, calendar: Calendar, withTimezone timezone: TimeZone = .current) {
        self.calendar = calendar
        self.calendar.timeZone = timezone
        self.strategy = strategy
    }
    
    func nextExecutionDate(for date: Date = Date()) -> Date {
        // TODO: check (convert) 12(am,pm)/24 format
        let dateStructure = date.asDateStructure(calendar)
        let nextExecutionDate = switch strategy.type {
        case .once: onlyOnceExecutionDate(dateStructure)
        case .repeatable: repeatableExecutionDate(dateStructure)
        case .daysOfWeek: daysOfWeekExecutionDate(dateStructure)
        case .daysOfMonth: daysOfMonthExecutionDate(dateStructure)
        }
        prevExecutionDate = nextExecutionDate
        return nextExecutionDate
    }
    
    private func isExecutionToday(_ date: DateStructure, useDate: Bool = false, useWeekday: Bool = false) -> Bool {
        let dateContains = useDate ? strategy.daysOfMonth.contains(date.day) : true
        let weekdayContains = useWeekday ? strategy.daysOfWeek.contains(date.weekday) : true
        
        while strategy.timeIterator.hasNext {
            let time = strategy.timeIterator.next()
            if dateContains && weekdayContains && date.isInclude(time: time) {
                return true
            }
        }
        
        return false
    }
    
    private func onlyOnceExecutionDate(_ date: DateStructure) -> Date {
        let todayExecution = isExecutionToday(date)
        let time = strategy.timeIterator.current!
        let nextDate = date
            .with(hours: time.hours, minutes: time.minutes, seconds: time.seconds)
            .asDate(calendar)
        strategy.timeIterator.drop()
        return todayExecution ? nextDate : nextDate.addingTimeInterval(1.days)
    }
    
    private func repeatableExecutionDate(_ date: DateStructure) -> Date {
        if let prevDate = prevExecutionDate {
            return prevDate.addingTimeInterval(strategy.repeatInterval)
        }
        return onlyOnceExecutionDate(date)
    }
    
    private func daysOfWeekExecutionDate(_ date: DateStructure) -> Date {
        let todayExecution = isExecutionToday(date, useWeekday: true)
        
        if let time = strategy.timeIterator.current, todayExecution {
            let nextDate = date
                .with(hours: time.hours, minutes: time.minutes, seconds: time.seconds)
                .asDate(calendar)
            return nextDate
        }
        
        strategy.timeIterator.drop()
        return newDaysOfWeekExecutionDate(date: date)
    }
    
    private func newDaysOfWeekExecutionDate(date: DateStructure) -> Date {
        while strategy.daysOfWeekIterator.hasNext {
            let dayOfWeek = strategy.daysOfWeekIterator.next()
            if dayOfWeek > date.weekday && strategy.timeIterator.hasNext {
                let time = strategy.timeIterator.next()
                return date
                    .with(hours: time.hours, minutes: time.minutes, seconds: time.seconds)
                    .asDate(calendar)
                    .addingTimeInterval((dayOfWeek - date.weekday).days)
            }
        }
        
        strategy.daysOfWeekIterator.drop()
        
        let dayOfWeek = strategy.daysOfWeekIterator.next()
        let time = strategy.timeIterator.next()
        let adding = calcWeekdaysDistance(from: date.weekday, to: dayOfWeek)
        return date
            .with(hours: time.hours, minutes: time.minutes, seconds: time.seconds)
            .asDate(calendar)
            .addingTimeInterval(adding.days)
    }
    
    private func calcWeekdaysDistance(from: Int, to: Int) -> Int {
        return 7 - (from - to)
    }
    
    private func daysOfMonthExecutionDate(_ date: DateStructure) -> Date {
        let todayExecution = isExecutionToday(date, useDate: true)
        
        if let time = strategy.timeIterator.current, todayExecution {
            let nextDate = date
                .with(hours: time.hours, minutes: time.minutes, seconds: time.seconds)
                .asDate(calendar)
            return nextDate
        }
        
        strategy.timeIterator.drop()
        return newDaysOfMonthExecutionDate(date: date)
    }
    
    private func newDaysOfMonthExecutionDate(date: DateStructure) -> Date {
        let daysInMonth = calendar.range(of: .day, in: .month, for: date.asDate(calendar))!
        
        while strategy.daysOfMonthIterator.hasNext {
            let dayOfMonth = strategy.daysOfMonthIterator.next()
            if dayOfMonth > date.day && daysInMonth.contains(dayOfMonth) && strategy.timeIterator.hasNext {
                let time = strategy.timeIterator.next()
                return date
                    .with(hours: time.hours, minutes: time.minutes, seconds: time.seconds)
                    .asDate(calendar)
                    .addingTimeInterval((dayOfMonth - date.day).days)
            }
        }
        
        strategy.daysOfMonthIterator.drop()
        
        let dayOfMonth = strategy.daysOfMonthIterator.next()
        let time = strategy.timeIterator.next()
        let adding = calcDatesDistance(from: date.day, to: dayOfMonth, daysInMonth: daysInMonth.count)
        return date
            .with(hours: time.hours, minutes: time.minutes, seconds: time.seconds)
            .asDate(calendar)
            .addingTimeInterval(adding.days)
    }
    
    private func calcDatesDistance(from: Int, to: Int, daysInMonth: Int) -> Int {
        return daysInMonth - from + to
    }
}
