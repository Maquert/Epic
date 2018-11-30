import XCTest
import Epic

class ThrottleTests: XCTestCase {
    fileprivate typealias Me = ThrottleTests

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

        Me.dispatch() { epic.throttle { firstTaskExp.fulfill() } }
        Me.dispatch(after: 0.1) { epic.throttle { secondTaskExp.fulfill() } }
        Me.dispatch(after: 0.2) { epic.throttle { thirdTaskExp.fulfill() } }

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

        Me.dispatch() { epic.throttle { firstTaskExp.fulfill() } }
        Me.dispatch(after: 0.3) { epic.throttle { secondTaskExp.fulfill() } }
        Me.dispatch(after: 0.6) { epic.throttle { thirdTaskExp.fulfill() } }

        wait(for: [firstTaskExp, secondTaskExp, thirdTaskExp], timeout: 0.9, enforceOrder: true)
    }

    // MARK: Utils

    static func dispatch(after: TimeInterval = 0, block: @escaping EpicBlock) {
        DispatchQueue.main.asyncAfter(deadline: .now() + after, execute: {
            block()
        })
    }
}
