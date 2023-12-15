# SwiftTaskScheduler

<p align="center">
    <a href="LICENSE">
        <img src="https://img.shields.io/badge/LICENSE-MIT-green.svg" alt="MIT License">
    </a>
    <a href="https://swift.org">
        <img src="https://img.shields.io/badge/swift-5.9-orange.svg" alt="Swift 5.9">
    </a>
</p>

SwiftTaskScheduler - Swift tool for running scheduled tasks on specific days and times, as well as those that are supposed to be executed at a certain time interval, i.e. backups, service health checks, deleting old files, etc.

## Usage example

Creates a task that runs only once at 15:30.

```swift
import SwiftTaskScheduler

let scheduler = TaskScheduler()

let task = scheduler.once(.at(15, 30)) {
    // DO SOME
}

// Or you can use default singleton instance of task scheduler
let task = TaskScheduler.default.once(.at(15, 30)) {
    // DO SOME
}
```

For creates scheduled tasks use task scheduler functions bellow:

```swift
// Creates repeatable tasks that will run at a specified time interval (starts at 00:00:00, and repeats every 30 minutes)
scheduler.start(.midnight, repeatEvery: 30.minutes) { }
// Starts 1 hour after creates that, and repeats every 3 hours
scheduler.start(after: 1.hours, repeatEvery: 3.hours) { }

// Creates a task that runs everyday at specified time 
scheduler.everyday(time: .midnight, .noon) { }

// Creates a task that runs every sun & sat
scheduler.weekends(time: .midnight) { }

// Creates a task that runs on the specified days of the week and time
scheduler.every(.monday, .tuesday, .thursday, time: .at(10)) { }

// Creates a task that runs on the specified days of the month and time
scheduler.every(1, 15, 30, time: .at(20, 30)) { }
```

For ease of management, the current task is transferred in the closure parameters. For example, if certain conditions are met, you can cancel further execution of the task:

```swift
// When a task is destroyed, it will also be deleted from the task scheduler
TaskScheduler.default.start(after: 0.seconds, repeatEvery: 30.minutes) { task in
    if condition {
        task.destroy()
    }
    // DO SOME
}

// You also can suspend and resume execution of task. The new execution time will be calculated, if needs.
task.suspend()
try task.resume()
```

For gracefully shutdown scheduler and tasks use `.invalidate()` method of `TaskScheduler` instance before deinit.

```swift
let scheduler = TaskScheduler()
...
scheduler.invalidate()
```

`ExecutionStrategy` type conforms `Codable` protocol for save and load it, and use on future for cold start tasks.

```swift
let data = try JSONSerialization.data(withJSONObject: [
    "type" : 1,
    "interval" : 60,
    "time" : [["hours": 15, "minutes": 30, "seconds": 0]]
])

// For example, we create a repeatable task from data received from somewhere
let decoder = JSONDecoder()
let strategy = try decoder.decode(ExecutionStrategy.self, from: data)
let task = JobTask(scheduler: TaskScheduler.default, strategy: strategy) { task in
    // DO SOME
}
```

## Adding `SwiftTaskScheduler` to your project

### Swift Package Manager

Add the following line to the 'dependencies' section of the `Package.swift` file:

```swift
dependencies: [
  .package(url: "https://github.com/egorbos/swift-task-scheduler.git", from: "0.1.0"),
],
```

### CocoaPods

Add the following line to the `Podfile`:

```text
pod 'SwiftTaskScheduler', :git => "https://github.com/egorbos/swift-task-scheduler.git", :tag => "0.1.0"
```

## Compatibility

Platform | Minimum version
--- | ---
macOS | 10.15 (Catalina)
iOS, iPadOS & tvOS | 13
watchOS | 6

## License

SwiftTaskScheduler is available under the MIT license. See the LICENSE file for more info.