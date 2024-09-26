import XCTest
import Epic

#if canImport(Combine)
import Combine

class ThrottleTests: XCTestCase {
    let queue = DispatchQueue(label: "test queue")

    /**
     * Three tasks are executed in a maximum window of 200 milliseconds.
     * All three are throttled every 100 milliseconds, which allows only two tasks to enter execution.
     * i.e: a user types a new character every 100 milliseconds and we only want to dispatch a query every 200 at much.
     */
    func testThrottleMultipleTasksButExecutesTheFirstAndTheLastOneOnly() {
        let dispatcher = TestDispatcher()
        let epic = ThrottleScheduledBy(
            interval: 1,
            scheduler: dispatcher.scheduler
        )

        var executedTasks = [Int]()

        let firstOperation = dispatcher.schedule(after: 0.1, block: {
            executedTasks.append(0)
        })
        let secondOperation = dispatcher.schedule(after: 0.11, block: {
            executedTasks.append(1)
        })
        let thirdOperation = dispatcher.schedule(after: 0.12, block: {
            executedTasks.append(2)
        })
        epic.throttle(futureOperation: firstOperation)
        epic.throttle(futureOperation: secondOperation)
        epic.throttle(futureOperation: thirdOperation)

        XCTAssertEqual(executedTasks, [0, 2])
    }

    func testCombineThrottle() {
        let scheduler = DispatchQueue.testableScheduler
        var executedTasks = [Int]()
        var enqueued = [Future<Int, Never>]()
        let cancellable = enqueued.publisher
            .throttle(for: 0, scheduler: DispatchQueue.main, latest: false)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { subscriber in print(subscriber) },
                receiveValue: { value in print(value) }
            )

        enqueued.append(Future { promise in
//            scheduler.schedule(after: scheduler.now.advanced(by: 1)) {
//                promise(.success(0))
//            }
            promise(.success(0))
        })
        enqueued.append(Future { promise in
//            scheduler.schedule(after: scheduler.now.advanced(by: 1)) {
//                promise(.success(1))
//            }
            promise(.success(1))
        })
        enqueued.append(Future { promise in
//            scheduler.schedule(after: scheduler.now.advanced(by: 1)) {
//                promise(.success(2))
//            }
            promise(.success(2))
        })

        XCTAssertEqual(executedTasks, [0, 2])
    }
}

struct TestDispatcher {
    let scheduler = DispatchQueue.testableScheduler

    func schedule(
        after: DispatchQueue.SchedulerTimeType.Stride,
        block: @escaping () -> Void
    ) -> FutureOperation {
        return FutureOperation { callback in
            scheduler.schedule(after: scheduler.now.advanced(by: after)) {
                callback(.success(block))
            }
            callback(.success(block))
        }
    }
}

#else
/**
 Legacy version tests with no schedulers.
 */
class ThrottleTests: XCTestCase {
    func testThrottleWorksWithASingleTask() {
        let epic = Throttle()
        let firstTaskExp = expectation(description: "Execution of the first task")

        epic.throttle { firstTaskExp.fulfill() }

        waitForExpectations(timeout: 1, handler: nil)
    }

    /**
     * Three tasks are executed in a maximum window of 200 milliseconds.
     * All three are throttled every 100 milliseconds, which allows only two tasks to enter execution.
     * i.e: a user types a new character every 100 milliseconds and we only want to dispatch a query every 200 at much.
     */
    func testThrottleMultipleTasksButExecutesTheFirstAndTheLastOneOnly() {
        let epic = Throttle(interval: 0.2)
        let firstTaskExp = expectation(description: "Execution of the first task")
        let secondTaskExp = expectation(description: "Execution of the second task")
        secondTaskExp.isInverted = true // Should not be executed
        let thirdTaskExp = expectation(description: "Execution of the third task")

        ThrottleTests.dispatch() { epic.throttle { firstTaskExp.fulfill() } }
        ThrottleTests.dispatch(after: 0.1) { epic.throttle { secondTaskExp.fulfill() } }
        ThrottleTests.dispatch(after: 0.2) { epic.throttle { thirdTaskExp.fulfill() } }

        wait(for: [firstTaskExp, secondTaskExp, thirdTaskExp], timeout: 0.5, enforceOrder: true)
    }

    /**
     * Three tasks are executed in a maximum window of 200 milliseconds.
     * All three are throttled every 300 milliseconds, which allows the three tasks to enter execution.
     * i.e: a user types a new character every 300 milliseconds and we only want to dispatch a query every 200 at much.
     */
    func testThrottleMultipleTasksAndExecutesAll() {
        let epic = Throttle(interval: 0.2)
        let firstTaskExp = expectation(description: "Execution of the first task")
        let secondTaskExp = expectation(description: "Execution of the second task")
        let thirdTaskExp = expectation(description: "Execution of the third task")

        ThrottleTests.dispatch() { epic.throttle { firstTaskExp.fulfill() } }
        ThrottleTests.dispatch(after: 0.3) { epic.throttle { secondTaskExp.fulfill() } }
        ThrottleTests.dispatch(after: 0.6) { epic.throttle { thirdTaskExp.fulfill() } }

        wait(for: [firstTaskExp, secondTaskExp, thirdTaskExp], timeout: 0.9, enforceOrder: true)
    }

    // MARK: Utils

    static func dispatch(after: TimeInterval = 0, block: @escaping EpicBlock) {
        DispatchQueue.main.asyncAfter(deadline: .now() + after, execute: {
            block()
        })
    }
}

#endif
