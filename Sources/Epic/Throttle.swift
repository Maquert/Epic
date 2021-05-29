import Foundation

/// Throttles tasks within time intervals.
/// Within every interval, only the last throttled task will be executed.
/// Tasks are always dispatched on the main queue.
public final class Throttle: ThrottleProtocol {
    private let queue: DispatchQueue = DispatchQueue.global(qos: .background)
    private var task: DispatchWorkItem = DispatchWorkItem(block: {})
    private var previousExecution: Date = Date.distantPast
    private var interval: TimeInterval

    /// Initializes with the interval of seconds within tasks are constrained to be executed
    public init(interval: TimeInterval = 1) {
        self.interval = interval
    }

    /// Throttles a block that will be only executed if no later requests are sent within the specified interval of time (100 milliseconds by default)
    public func throttle(block: @escaping EpicBlock) {
        self.throttle(block: block, onQueue: .main)
    }

    private func throttle(
        block: @escaping EpicBlock,
        onQueue queue: DispatchQueue = .main
    ) {
        self.task.cancel()
        self.task = DispatchWorkItem() { [weak self] in
            self?.previousExecution = Date()
            queue.async {
                block()
            }
        }
        let delay = Throttle.second(from: self.previousExecution) > self.interval ? 0 : self.interval
        self.queue.asyncAfter(
            deadline: .now() + Double(delay),
            execute: self.task
        )
    }

    private static func second(
        from referenceDate: Date,
        now: Date = Date()
    ) -> TimeInterval {
        return now.timeIntervalSince(referenceDate)
    }
}
