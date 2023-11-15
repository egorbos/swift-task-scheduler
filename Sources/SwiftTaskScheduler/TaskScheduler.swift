import Foundation

public final class TaskScheduler {
    
    private var tasks: [String: JobTask]
    
    private static let _default = TaskScheduler()
    
    public class var `default`: TaskScheduler {
        return _default
    }
    
    public init() {
        self.tasks = [:]
    }
    
    internal func addTask(_ task: JobTask) {
        tasks[task.id] = task
    }
    
    internal func getTask(by id: String) -> JobTask? {
        return tasks[id]
    }
    
    internal func removeTask(by id: String) {
        // deinit task
        tasks.removeValue(forKey: id)
    }
}
