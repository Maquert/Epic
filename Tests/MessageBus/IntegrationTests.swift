import XCTest
import Epic

class IntegrationTests: XCTestCase {
    var messageBus: MessageBus!
    var broker: Broker!
    var topic: DryTopic!

    func testEmptyEventBus() {
        givenAnEmptyState()

        assertEmptyState()
    }

    func testRunningEventBusWith1Message() {
        givenAnEmptyState()

        let reachedEnd = expectation(description: "The message reached the topic")
        broker.subscribe()
        topic.onChange = { messages in
            if messages.count == 1 {
                reachedEnd.fulfill()
            }
        }
        messageBus.send(messages: messages(count: 1))
        waitForExpectations(timeout: 1, handler: nil)

        assertState(withNumberOfProcessedItems: 1)
    }

    func testRunningEventBusWith10Messages() {
        givenAnEmptyState()

        let reachedEnd = expectation(description: "The 10 messages reached the topic")
        broker.subscribe()
        topic.onChange = { messages in
            if messages.count == 10 {
                reachedEnd.fulfill()
            }
        }
        messageBus.send(messages: messages(count: 10))
        waitForExpectations(timeout: 1, handler: nil)

        assertState(withNumberOfProcessedItems: 10)
    }

    func testRunningEventBusWith200Messages() { // ! Load test
        givenAnEmptyState()

        let reachedEnd = expectation(description: "The 200 messages reached the topic")
        broker.subscribe()
        topic.onChange = { messages in
            if messages.count == 200 {
                reachedEnd.fulfill()
            }
        }
        messageBus.send(messages: messages(count: 200))
        waitForExpectations(timeout: 2, handler: nil)

        assertState(withNumberOfProcessedItems: 200)
    }

    func testMessagesArriveToTopicsWhenBrokerLaunchesAfterMessageBusHasStoredThem() {
        givenAnEmptyState()

        let reachedEnd = expectation(description: "The 1000 messages reached the topic")
        topic.onChange = { messages in
            if messages.count == 10 {
                reachedEnd.fulfill()
            }
        }
        messageBus.send(messages: messages(count: 10))
        broker.subscribe()
        waitForExpectations(timeout: 1, handler: nil)

        assertState(withNumberOfProcessedItems: 10)
    }

    func testTwoConcurrentTopicsReceivedTheirMessages() {
        givenAnEmptyStateForMultipleTopics()

        let reachedEndTopic0 = expectation(description: "The 1000 messages reached the topic 0")
        let reachedEndTopic1 = expectation(description: "The 1000 messages reached the topic 1")
        let dryBroker = self.broker as? DryBroker
        dryBroker?.topic(name: "testing_topic_0")?.onChange = { messages in
            if messages.count == 10 {
                reachedEndTopic0.fulfill()
            }
        }
        dryBroker?.topic(name: "testing_topic_1")?.onChange = { messages in
            if messages.count == 10 {
                reachedEndTopic1.fulfill()
            }
        }
        messageBus.send(messages: messages(count: 10))
        broker.subscribe()
        waitForExpectations(timeout: 1, handler: nil)
    }

    // MARK: Given

    func givenAnEmptyState() {
        self.messageBus = MessageBus()
        self.topic = DryTopic(name: "testing_topic_0")
        self.broker = DryBroker(topic: self.topic, messageBus: self.messageBus)
    }

    func givenAnEmptyStateForMultipleTopics() {
        self.messageBus = MessageBus()
        let topic1 = DryTopic(name: "testing_topic_0")
        let topic2 = DryTopic(name: "testing_topic_1")
        self.broker = DryBroker(topics: [topic1, topic2], messageBus: self.messageBus)
    }

    func messages(count: Int) -> [Epic.Message] {
        return (0..<count).map { _ in return Message(types: ["test_type", "another_type"], payload: nil) }
    }

    func assertEmptyState() {
        XCTAssertEqual(messageBus.numberOfMessages, 0)
        XCTAssertFalse(broker.fetching)
        XCTAssertEqual(topic.messages.count, 0)
    }

    func assertState(withNumberOfProcessedItems count: Int) {
        XCTAssertEqual(messageBus.numberOfMessages, 0)
        XCTAssertTrue(broker.fetching)
        XCTAssertEqual(topic.messages.count, count)
    }
}

class DryBroker: Broker {
    var topics: [DryTopic]

    init(topic: DryTopic, messageBus: MessageBusProtocol) {
        self.topics = [topic]
        super.init(messageBus: messageBus, pollingLoad: 1, pollingTime: 0.001)
    }

    init(topics: [DryTopic], messageBus: MessageBusProtocol) {
        self.topics = topics
        super.init(messageBus: messageBus, pollingLoad: 1, pollingTime: 0.001)
    }

    private let typeAndTopic = [
        "test_type": "testing_topic_0",
        "another_type": "testing_topic_1"
    ]

    override func fetch(messages: [Message]) {
        let testTypeMessages = messages.filter { $0.types.contains("test_type") }
        let anotherTypeMessages = messages.filter { $0.types.contains("another_type") }

        typeAndTopic.forEach { (key, value) in
            var topic = self.topic(name: value)

            switch value {
            case "testing_topic_0":
                topic?.store(messages: testTypeMessages)
            case "testing_topic_1":
                topic?.store(messages: anotherTypeMessages)
            default: break
            }
        }
    }

    public func topic(name: String) -> DryTopic? {
        return self.topics.first(where: { $0.name == name })
    }
}

class DryTopic: Topic {
    var lastIndex: Int
    let name: String
    var messages = [Epic.Message]() {
        didSet(oldMessages) {
            if self.messages.count != oldMessages.count {
                self.onChange?(self.messages)
            }
        }
    }
    var onChange: (([Epic.Message]) -> Void)?

    init(name: String = "Test topic") {
        self.name = name
        self.lastIndex = 0

        self.onChange = nil
    }
}
