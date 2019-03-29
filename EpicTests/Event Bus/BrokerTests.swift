import XCTest
import Epic

class BrokerTests: XCTestCase {
    var lane: MessageBusProtocol!
    var sut: Broker!

    override func tearDown() {
        sut = nil
        lane = nil
        super.tearDown()
    }

    func testBrokerWithEmptyLane() {
        givenAnEmptyLane()

        let extraction = expectation(description: "Execution of an empty extraction")
        sut.subscribe { (messages) in
            guard messages.count == 0 else { return }
            extraction.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testBrokerWithALaneOfThreeItems() {
        givenALane(withNumberOfMessages: 3)

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

    func givenAnEmptyLane() {
        self.lane = MessageBus()
        self.sut = Broker(messageBus: self.lane, pollingLoad: 1, pollingTime: 1)
    }

    func givenALane(withNumberOfMessages count: Int) {
        self.lane = MessageBus()
        self.sut = Broker(messageBus: self.lane, pollingLoad: 1, pollingTime: 1)

        let messages = (0..<count).map { Message(types: ["test_" + String($0)], payload: nil) }
        self.lane.send(messages: messages)
    }
}
