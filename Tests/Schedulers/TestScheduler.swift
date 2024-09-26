#if canImport(Combine)
import Combine

public final class TestScheduler<SchedulerTimeType, SchedulerOptions>: Scheduler
where SchedulerTimeType: Strideable, SchedulerTimeType.Stride: SchedulerTimeIntervalConvertible
{
    typealias ScheduledItem = (UInt, SchedulerTimeType, () -> Void)

    public private(set) var now: SchedulerTimeType

    public private(set) var minimumTolerance: SchedulerTimeType.Stride = .zero

    /// The sequence of items to be dispatched
    private var scheduled: [(
        sequenceIndex: UInt,
        date: SchedulerTimeType,
        action: () -> Void
    )] = []

    /// Keeps the internal index of the last disptached item
    private var previousSequenceIndex: UInt = 0

    // MARK: Init

    /// Creates a test scheduler with the given date.
    ///
    /// - Parameter now: The current date of the test scheduler.
    public init(now: SchedulerTimeType) {
        self.now = now
    }

    // MARK: Protocol conformace

    /// Performs the action at the next possible opportunity.
    public func schedule(
        options: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) {
        self.scheduled.append(
            Self.scheduledItem(
                index: self.nextSequenceIndex(),
                date: self.now,
                action: action
            )
        )
    }

    /// Performs the action at some time after the specified date.
    public func schedule(
        after date: SchedulerTimeType,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) {
        self.scheduled.append(
            Self.scheduledItem(
                index: self.nextSequenceIndex(),
                date: date,
                action: action
            )
        )
    }

    /// Performs the action at some time after the specified date, at the specified frequency, optionally taking into account tolerance if possible.
    public func schedule(
        after date: SchedulerTimeType,
        interval: SchedulerTimeType.Stride,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) -> Cancellable {
        let sequenceIndex = self.nextSequenceIndex()

        func scheduleAction(for date: SchedulerTimeType) -> () -> Void {
            return { [weak self] in
                let nextDate = date.advanced(by: interval)
                self?.scheduled.append(
                    Self.scheduledItem(
                        index: sequenceIndex,
                        date: nextDate,
                        action: scheduleAction(for: nextDate)
                    )
                )
                action()
            }
        }

        self.scheduled.append(
            Self.scheduledItem(
                index: sequenceIndex,
                date: date,
                action: scheduleAction(for: date)
            )
        )

        return AnyCancellable { [weak self] in
            self?.scheduled.removeAll(where: { $0.sequenceIndex == sequenceIndex })
        }
    }

    public func run() {
        while let date = self.scheduled.first?.date {
            self.advance(by: self.now.distance(to: date))
        }
    }

    public func advance(by stride: SchedulerTimeType.Stride = .zero) {
        let finalDate = self.now.advanced(by: stride)

        while self.now <= finalDate {
            self.scheduled.sort { ($0.date, $0.sequenceIndex) < ($1.date, $1.sequenceIndex) }

            guard
                let nextDate = self.scheduled.first?.date,
                finalDate >= nextDate
            else {
                self.now = finalDate
                return
            }

            self.now = nextDate

            while let (_, date, action) = self.scheduled.first, date == nextDate {
                self.scheduled.removeFirst()
                action()
            }
        }
    }

    // MARK: Private

    /// Returns a ScheduledItem (a tuple).
    private static func scheduledItem(
        index: UInt,
        date: SchedulerTimeType,
        action: @escaping () -> Void
    ) -> ScheduledItem {
        (index, date, action)
    }

    /// Updates the internal `previousSequenceIndex` index
    /// - Returns: The next sequence index.
    ///     This index could also be retrieved by accessing `previousSequenceIndex`.
    private func nextSequenceIndex() -> UInt {
        self.previousSequenceIndex += 1
        return self.previousSequenceIndex
    }
}

#endif
