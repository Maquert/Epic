#if canImport(Combine)
import Combine
#endif

public struct Testable {
    #if canImport(Combine)
    /// Represents a Scheduler type with an associated type and options the original scheduler wraps.
    /// Use it as `Testable.SchedulerUsing<DispatchQueue>`.
    public typealias SchedulerUsing<Scheduler> = TestScheduler<
        Scheduler.SchedulerTimeType, Scheduler.SchedulerOptions
    > where Scheduler: Combine.Scheduler
    #endif
}
