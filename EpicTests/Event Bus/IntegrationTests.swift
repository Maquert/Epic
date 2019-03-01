//
//  IntegrationTests.swift
//  EpicTests
//
//  Created by Miguel Hernández Jaso on 01/03/2019.
//  Copyright © 2019 Miguel Hernández Jaso. All rights reserved.
//

import XCTest
import Epic

class IntegrationTests: XCTestCase {
    var lane: MessageBus!
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
        lane.send(messages: messages(count: 1))
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
        lane.send(messages: messages(count: 10))
        waitForExpectations(timeout: 1, handler: nil)

        assertState(withNumberOfProcessedItems: 10)
    }

    func testRunningEventBusWith1000Messages() { // ! Load test
        givenAnEmptyState()

        let reachedEnd = expectation(description: "The 1000 messages reached the topic")
        broker.subscribe()
        topic.onChange = { messages in
            if messages.count == 1000 {
                reachedEnd.fulfill()
            }
        }
        lane.send(messages: messages(count: 1000))
        waitForExpectations(timeout: 2, handler: nil) // 1000 messages won't make it in 0.001 seconds

        assertState(withNumberOfProcessedItems: 1000)
    }

    func testMessagesArriveToTopicsWhenBrokerLaunchesAfterMessageBusHasStoredThem() {
        givenAnEmptyState()

        let reachedEnd = expectation(description: "The 1000 messages reached the topic")
        topic.onChange = { messages in
            if messages.count == 10 {
                reachedEnd.fulfill()
            }
        }
        lane.send(messages: messages(count: 10))
        broker.subscribe()
        waitForExpectations(timeout: 1, handler: nil)

        assertState(withNumberOfProcessedItems: 10)
    }

    func testTwoConcurrentTopicsReceivedTheirMessages() {
        // WIP: Support for multiple topics
        // DryBroker(topics: [topic1, topic2], lane: self.lane)
    }

    // MARK: Given

    func givenAnEmptyState() {
        self.lane = MessageBus()
        self.topic = DryTopic(name: "testing_topic")
        self.broker = DryBroker(topic: self.topic, lane: self.lane)
    }

    func messages(count: Int) -> [Epic.Message] {
        return (0..<count).map { _ in return Message(types: ["test_type"], payload: nil) }
    }

    func assertEmptyState() {
        XCTAssertEqual(lane.numberOfMessages, 0)
        XCTAssertFalse(broker.fetching)
        XCTAssertEqual(topic.messages.count, 0)
    }

    func assertState(withNumberOfProcessedItems count: Int) {
        XCTAssertEqual(lane.numberOfMessages, 0)
        XCTAssertTrue(broker.fetching)
        XCTAssertEqual(topic.messages.count, count)
    }
}

class DryBroker: Broker {
    var topic: DryTopic

    init(topic: DryTopic, lane: MessageBusProtocol) {
        self.topic = topic
        super.init(lane: lane, pollingLoad: 1, pollingTime: 0.001)
    }

    

    override func fetch(messages: [Message]) {
        messages.forEach { (message) in
            if message.types.contains("test_type") {
                self.topic.store(messages: [message])
            }
        }
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
