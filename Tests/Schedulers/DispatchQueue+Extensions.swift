#if canImport(Combine)
import Combine
import Foundation

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension DispatchQueue {
    typealias TestableScheduler = Testable.SchedulerUsing<DispatchQueue>
    /// A scheduler for testing purposes for `DispatchQueue` schedulers.
    public static var testableScheduler: Testable.SchedulerUsing<DispatchQueue> {
        let dispatchTime = DispatchTime(uptimeNanoseconds: 1)
        let scheduler = SchedulerTimeType(dispatchTime)
        return .init(now: scheduler)
    }
}

#endif
