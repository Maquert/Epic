import XCTest
import Epic

class TopicTests: XCTestCase {
    var lane: MessageBusProtocol!
    var sut: Topic!

    func testEmptyTopic() {
        givenAnEmptyTopic()

        assertEmptyTopic()
    }

    func testFreshTopicAdding3MessagesReturnsThreeLastMessages() {
        givenAnEmptyTopic()

        sut.store(messages: self.messages(count: 3))

        assertNewMessages(numberOfMessages: 3)
    }

    func testFreshTopicAdding3And2MessagesReturnsTwoLastMessages() {
        givenAnEmptyTopic()

        sut.store(messages: self.messages(count: 3, starting: 0))
        sut.store(messages: self.messages(count: 8, starting: 10))

        assertNewMessages(numberOfMessages: 8)
    }

    // MARK: Given

    func givenAnEmptyTopic() {
        self.sut = DryTopic()
    }

    func messages(count: Int, starting: Int = 0) -> [Epic.Message] {
        return (0..<count).map { Message(types: ["test_" + String($0+starting)], payload: nil) }
    }

    func assertEmptyTopic() {
        XCTAssertEqual(self.sut.messages.count, 0)
        assertNewMessages(numberOfMessages: 0)
    }

    func assertFullfilledTopic(numberOfMessages: Int) {
        XCTAssertEqual(self.sut.messages.count, numberOfMessages)
    }

    func assertNewMessages(numberOfMessages: Int) {
        XCTAssertEqual(self.sut.newMessages.count, numberOfMessages)
    }
}

