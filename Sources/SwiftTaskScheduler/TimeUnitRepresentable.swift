import Foundation

public protocol TimeUnitRepresentable {
    var seconds: TimeInterval { get }
    var minutes: TimeInterval { get }
    var hours: TimeInterval { get }
    var days: TimeInterval { get }
}

extension Int: TimeUnitRepresentable {
    public var seconds: TimeInterval {
        TimeInterval(self)
    }
    
    public var minutes: TimeInterval {
        TimeInterval(self * 60)
    }
    
    public var hours: TimeInterval {
        TimeInterval(self * 60 * 60)
    }
    
    public var days: TimeInterval {
        TimeInterval(self * 60 * 60 * 24)
    }
}

extension Double: TimeUnitRepresentable {
    public var seconds: TimeInterval {
        TimeInterval(self)
    }
    
    public var minutes: TimeInterval {
        TimeInterval(self * 60)
    }
    
    public var hours: TimeInterval {
        TimeInterval(self * 60 * 60)
    }
    
    public var days: TimeInterval {
        TimeInterval(self * 60 * 60 * 24)
    }
}
