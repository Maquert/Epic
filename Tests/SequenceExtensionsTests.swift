import XCTest
import Epic

class SequenceExtensionsTests: XCTestCase {
    var sut: [(Int) -> Bool]!
    let array = Array(0..<10)

    func testFilterWithEmptyArrayOfFilters() {
        givenAnEmptyListOfFilters()

        let result = array.filter(with: sut)

        assertFullArray(array: result)
    }

    func testFilterWithOnlyEvenNumbers() {
        givenAListOfFiltersForEvenNumbers()

        let result = array.filter(with: sut)

        assertArrayOfEvenNumbers(array: result)
    }

    func testFilterWithOnlyOddNumbers() {
        givenAListOfFiltersForOddNumbers()

        let result = array.filter(with: sut)

        assertArrayOfOddNumbers(array: result)
    }

    func testFilterWithNoOddOrEvenNumbers() {
        givenAListOfFiltersForEvenAndOddNumbers()

        let result = array.filter(with: sut)

        assertEmptyArray(array: result)
    }

    // MARK: Assertions

    func givenAnEmptyListOfFilters() {
        sut = [(Int) -> Bool]()
    }

    func givenAListOfFiltersForEvenNumbers() {
        sut = [{ return $0 % 2 == 0 }]
    }

    func givenAListOfFiltersForOddNumbers() {
        sut = [{ return $0 % 2 != 0 }]
    }

    func givenAListOfFiltersForEvenAndOddNumbers() {
        sut = [{ return $0 % 2 != 0 }, { return $0 % 2 == 0 }]
    }

    func assertFullArray(array: [Int]) {
        XCTAssertEqual(array.count, 10)
        XCTAssertEqual(array.first, 0)
        XCTAssertEqual(array.last, 9)
    }

    func assertArrayOfEvenNumbers(array: [Int]) {
        XCTAssertEqual(array.count, 5)
        XCTAssertEqual(array.first, 0)
        XCTAssertEqual(array.last, 8)
    }

    func assertArrayOfOddNumbers(array: [Int]) {
        XCTAssertEqual(array.count, 5)
        XCTAssertEqual(array.first, 1)
        XCTAssertEqual(array.last, 9)
    }

    func assertEmptyArray(array: [Int]) {
        XCTAssertEqual(array.count, 0)
        XCTAssertEqual(array.first, nil)
    }
}
