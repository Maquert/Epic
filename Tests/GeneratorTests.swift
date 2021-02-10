import XCTest
import Epic

class GeneratorTests: XCTestCase {
    func testAppLaunchGenerator() {
        let operations: [Epic.Operation] = [
            Epic.Operation("app.dismiss_current_modal", block: nil),
            Epic.Operation("app.open.safari_vc", block: nil),
            ]
        let generator = Epic.Generator(operations: operations)
        var epicIterator = generator.iterator()

        XCTAssertEqual(epicIterator.next()?.identifier, "app.dismiss_current_modal")
        XCTAssertEqual(epicIterator.next()?.identifier, "app.open.safari_vc")
        XCTAssertTrue(epicIterator.finished) // Operations are finished
    }

    func testRunGenerator() {
        let operations: [Epic.Operation] = [
            Epic.Operation("app.dismiss_current_modal", block: nil),
            Epic.Operation("app.open.safari_vc", block: nil),
            ]
        let generator = Epic.Generator(operations: operations)

        let epicIterator = generator.run()
        XCTAssertEqual(epicIterator.lastIndex, 2)
        XCTAssertTrue(epicIterator.finished) // Operations are finished
    }
}
