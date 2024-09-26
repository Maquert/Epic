import Foundation
#if canImport(Combine)
import Combine
#endif

#if canImport(Combine)
public typealias FutureOperation = Future<EpicBlock, Never>

/**
 Publishes the first and most-recent block published by the upstream publisher
 in the specified time interval.

 Overwrite `usesLatest` to prevent the most-recent block from being executed.
 */
public final class ThrottleScheduledBy<S: Scheduler> {

    /// A Boolean value that indicates whether to publish the most recent element. If false, the publisher emits the first element received during the interval.
    public var usesLatest: Bool = true

    public private(set) var interval: S.SchedulerTimeType.Stride
    private var blockCancellable: AnyCancellable?
    @Published private var operations = [FutureOperation]()
    public let scheduler: S

    public init(
        interval: S.SchedulerTimeType.Stride,
        scheduler: S
    ) {
        self.interval = interval
        self.scheduler = scheduler
    }

    /// Throttles a block that will be only executed if no later requests are sent within the specified interval of time
    public func throttle(block: @escaping () -> Void) {
        let futureOperation = FutureOperation { callback in
            callback(.success(block))
        }
        self.throttle(futureOperation: futureOperation)
    }

    /// Throttles a promise block that will be only executed if no later requests are sent within the specified interval of time
    public func throttle(futureOperation: FutureOperation) {
        initializeThrottling()
        operations.append(futureOperation)
    }

    /// Starts throttling with a cancellable subscriber.
    /// It will only initialize a cancellable subscriber if the current one is nil.
    private func initializeThrottling() {
        if blockCancellable == nil { // Delays throttle publishing until its first execution
            blockCancellable = startThrottling(
                usesLatest: usesLatest,
                scheduler: scheduler
            )
        }
    }

    /// Creates a cancellable subscriber to blocks appended to the operations variable.
    private func startThrottling(
        usesLatest: Bool,
        scheduler: S
    ) -> AnyCancellable {
        $operations
            .throttle(
                for: 1,
                scheduler: scheduler,
                latest: usesLatest
            )
            .compactMap(\.last)
            .sink { [weak self] result in
                //                result()
                self?.operations.removeAll()
            }
    }
}
#endif
