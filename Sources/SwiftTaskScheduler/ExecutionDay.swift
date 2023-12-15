/// Represents the day of the week on which the task is scheduled to run.
public enum ExecutionDay: Int, CaseIterable {
    case sunday    = 1
    case monday    = 2
    case tuesday   = 3
    case wednesday = 4
    case thursday  = 5
    case friday    = 6
    case saturday  = 7
}

extension ExecutionDay: Comparable {
    public static func < (lhs: ExecutionDay, rhs: ExecutionDay) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
