import Foundation

internal extension Date {
    func asDateStructure(_ calendar: Calendar) -> DateStructure {
        let dateComponents = calendar
            .dateComponents([.year, .month, .day, .weekday, .hour, .minute, .second], from: Date())
        return DateStructure(
            year: dateComponents.year!, month: dateComponents.month!, day: dateComponents.day!, weekday: dateComponents.weekday!,
            hours: dateComponents.hour!, minutes: dateComponents.minute!, seconds: dateComponents.second!
        )
    }
}
