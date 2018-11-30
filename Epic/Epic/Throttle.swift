import Foundation

/// Throttles tasks within time intervals.
/// Within every interval, only the last throttled task will be executed.
/// Tasks are always dispatched on the main queue.
public class Throttle {
    fileprivate typealias Me = Throttle

    private let queue: DispatchQueue = DispatchQueue.global(qos: .background)
    private var task: DispatchWorkItem = DispatchWorkItem(block: {})
    private var previousExecution: Date = Date.distantPast
    private var interval: TimeInterval

    /// Initializes with the interval of seconds within tasks are constrained to be executed
    public init(interval: TimeInterval = 1) {
        self.interval = interval
    }

    /// Throttles a block that will be only executed if no later requests are sent within the specified interval of time (100 milliseconds by default)
    public func throttle(block: EpicBlock?) {
        self.task.cancel()
        self.task = DispatchWorkItem() { [weak self] in
            self?.previousExecution = Date()
            DispatchQueue.main.async {
                block?()
            }
        }
        let delay = Me.second(from: self.previousExecution) > self.interval ? 0 : self.interval
        self.queue.asyncAfter(deadline: .now() + Double(delay), execute: self.task)
    }

    private static func second(from referenceDate: Date) -> TimeInterval {
        return Date().timeIntervalSince(referenceDate)
    }
}
