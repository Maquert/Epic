import Foundation
#if canImport(Combine)
import Combine
#endif

#if canImport(Combine)
/**
 Publishes the first and most-recent block published by the upstream publisher
 in the specified time interval.
 
 Overwrite `usesLatest` to prevent the most-recent block from being executed.
 */
public final class Throttle: ThrottleProtocol {
    /// A Boolean value that indicates whether to publish the most recent element. If false, the publisher emits the first element received during the interval.
    public var usesLatest: Bool = true
    
    private var interval: TimeInterval
    private var blockCancellable: AnyCancellable?
    @Published private var operations = [EpicBlock]()
    
    /// Initializes with the interval of seconds within tasks are constrained to be executed
    /// Defaults to 1 second.
    public init(interval: TimeInterval = 1) {
        self.interval = interval
    }
    
    /// Throttles a block that will be only executed if no later requests are sent within the specified interval of time
    public func throttle(block: @escaping () -> Void) {
        if self.blockCancellable == nil { // Delays throttle publishing until its first execution
            self.blockCancellable = startThrottling(
                scheduler: .main,
                usesLatest: self.usesLatest
            )
        }
        self.operations.append(block)
    }
    
    /// Creates a cancellable subscriber to blocks appended to the operations variable.
    private func startThrottling(scheduler: RunLoop, usesLatest: Bool) -> AnyCancellable {
        self.$operations
            .throttle(
                for: RunLoop.SchedulerTimeType.Stride(self.interval),
                scheduler: scheduler,
                latest: usesLatest
            )
            .compactMap(\.last)
            .sink { [weak self] lastBlock in
                lastBlock()
                self?.operations.removeAll()
            }
    }
}
#else

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
#endif
