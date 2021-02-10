import XCTest
import Epic

class MessageBusTests: XCTestCase {
    var sut: MessageBus!

    func testEmptyMessageBus() {
        givenAnEmptyMessageBus()

        assertEmptyMessageBus()
    }

    func testSendOneMessagesToMessageBusReturnsOneMessage() {
        givenAnEmptyMessageBus()

        sut.send(message: Message(types: ["test_0"], payload: nil))

        assertMessageBus(withNumberOfMessages: 1)
    }

    func testSendFiveMessagesToMessageBusReturnsFiveMessages() {
        givenAMessageBus(withNumberOfMessages: 5)

        assertMessageBus(withNumberOfMessages: 5)
    }

    func testExtractTwoItemsFromAQueueOfFiveReturnsThreeRemainingItems() {
        givenAMessageBus(withNumberOfMessages: 5)

        _ = sut.extract(numberOfMessages: 2)

        assertMessageBus(withNumberOfMessages: 3)
    }

    func testExtractZeroItemsFromAQueueOfFiveReturnsFiveRemainingItems() {
        givenAMessageBus(withNumberOfMessages: 5)

        _ = sut.extract(numberOfMessages: 0)

        assertMessageBus(withNumberOfMessages: 5)
    }

    func testExtractSixItemsFromAQueueOfFiveReturnsZeroRemainingItems() {
        givenAMessageBus(withNumberOfMessages: 5)

        _ = sut.extract(numberOfMessages: 6)

        assertMessageBus(withNumberOfMessages: 0)
    }

    func testExtractedMessagesReturnsOldestOnesInReversedOrderOfAddition() {
        givenAnEmptyMessageBus()
        sut.send(message: Message(types: ["first_test"], payload: nil))
        sut.send(message: Message(types: ["second_test"], payload: nil))
        sut.send(message: Message(types: ["third_test"], payload: nil))

        let messages = sut.extract(numberOfMessages: 3)

        XCTAssertEqual(messages.first?.types.first, "third_test")
        XCTAssertEqual(messages.last?.types.first, "first_test")
    }

    func testExtractedMessagesReturnsOldestOnesInOrderOfAddition() {
        givenAnEmptyMessageBus()
        sut.send(message: Message(types: ["first_test"], payload: nil))
        sut.send(message: Message(types: ["second_test"], payload: nil))
        sut.send(message: Message(types: ["third_test"], payload: nil))

        let message1 = sut.extract(numberOfMessages: 1).first!
        let message2 = sut.extract(numberOfMessages: 1).first!
        let message3 = sut.extract(numberOfMessages: 1).first!

        XCTAssertEqual(message1.types.first, "first_test")
        XCTAssertEqual(message2.types.first, "second_test")
        XCTAssertEqual(message3.types.first, "third_test")
    }

    func testExtractedMessagesReturnsOldestOnesInReversedOrderWhenAddedInBatch() {
        givenAnEmptyMessageBus()
        sut.send(messages: [
            Message(types: ["first_test"], payload: nil),
            Message(types: ["second_test"], payload: nil),
            Message(types: ["third_test"], payload: nil)
            ])

        let messages = sut.extract(numberOfMessages: 3)

        XCTAssertEqual(messages.first?.types.first!, "third_test")
        XCTAssertEqual(messages.last?.types.first!, "first_test")
    }

    func testExtractedMessagesReturnsOldestOnesInOrderOfAdditionWhenAddedInBatch() {
        givenAnEmptyMessageBus()
        sut.send(messages: [
            Message(types: ["first_test"], payload: nil),
            Message(types: ["second_test"], payload: nil),
            Message(types: ["third_test"], payload: nil)
            ])

        let message1 = sut.extract(numberOfMessages: 1).first!
        let message2 = sut.extract(numberOfMessages: 1).first!
        let message3 = sut.extract(numberOfMessages: 1).first!

        XCTAssertEqual(message1.types.first, "first_test")
        XCTAssertEqual(message2.types.first, "second_test")
        XCTAssertEqual(message3.types.first, "third_test")
    }

    // MARK: Given

    func givenAnEmptyMessageBus() {
        self.sut = MessageBus()
    }

    func givenAMessageBus(withNumberOfMessages count: Int) {
        self.sut = MessageBus()
        let messages = (0..<count).map { Message(types: ["test_" + String($0)], payload: nil) }
        self.sut.send(messages: messages)
    }

    // MARK: Assert

    func assertEmptyMessageBus() {
        XCTAssertEqual(sut.numberOfMessages, 0)
    }

    func assertMessageBus(withNumberOfMessages count: Int) {
        XCTAssertEqual(sut.numberOfMessages, count)
    }
}
