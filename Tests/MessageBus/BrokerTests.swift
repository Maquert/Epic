import XCTest
import Epic

class BrokerTests: XCTestCase {
    var messageBus: MessageBusProtocol!
    var sut: Broker!

    override func tearDown() {
        sut = nil
        messageBus = nil
        super.tearDown()
    }

    func testBrokerWithEmptyMessageBus() {
        givenAnEmptyMessageBus()

        let extraction = expectation(description: "Execution of an empty extraction")
        sut.subscribe { (messages) in
            guard messages.count == 0 else { return }
            extraction.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testBrokerWithAMessageBusOfThreeItems() {
        givenAMessageBus(withNumberOfMessages: 3)

        var fetchedMessagesCount = 0
        let extraction = expectation(description: "Execution of an full extraction")
        sut.subscribe { (messages) in
            fetchedMessagesCount += messages.count
            if fetchedMessagesCount == 3 {
                extraction.fulfill()
            }
        }

        waitForExpectations(timeout: 3, handler: nil)
    }

    // MARK: Given

    func givenAnEmptyMessageBus() {
        self.messageBus = MessageBus()
        self.sut = Broker(messageBus: self.messageBus, pollingLoad: 1, pollingTime: 1)
    }

    func givenAMessageBus(withNumberOfMessages count: Int) {
        self.messageBus = MessageBus()
        self.sut = Broker(messageBus: self.messageBus, pollingLoad: 1, pollingTime: 1)

        let messages = (0..<count).map { Message(types: ["test_" + String($0)], payload: nil) }
        self.messageBus.send(messages: messages)
    }
}
