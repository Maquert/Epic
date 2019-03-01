//
//  LaneEventBusTests.swift
//  EpicTests
//
//  Created by Miguel Hernández Jaso on 28/02/2019.
//  Copyright © 2019 Miguel Hernández Jaso. All rights reserved.
//

import XCTest
import Epic

class LaneEventBusTests: XCTestCase {
    var sut: MessageBus!

    func testEmptyLane() {
        givenAnEmptyLane()

        assertEmptyLane()
    }

    func testSendOneMessagesToLaneReturnsOneMessage() {
        givenAnEmptyLane()

        sut.send(message: Message(types: ["test_0"], payload: nil))

        assertLane(withNumberOfMessages: 1)
    }

    func testSendFiveMessagesToLaneReturnsFiveMessages() {
        givenALane(withNumberOfMessages: 5)

        assertLane(withNumberOfMessages: 5)
    }

    func testExtractTwoItemsFromAQueueOfFiveReturnsThreeRemainingItems() {
        givenALane(withNumberOfMessages: 5)

        _ = sut.extract(numberOfMessages: 2)

        assertLane(withNumberOfMessages: 3)
    }

    func testExtractZeroItemsFromAQueueOfFiveReturnsFiveRemainingItems() {
        givenALane(withNumberOfMessages: 5)

        _ = sut.extract(numberOfMessages: 0)

        assertLane(withNumberOfMessages: 5)
    }

    func testExtractSixItemsFromAQueueOfFiveReturnsZeroRemainingItems() {
        givenALane(withNumberOfMessages: 5)

        _ = sut.extract(numberOfMessages: 6)

        assertLane(withNumberOfMessages: 0)
    }

    func testExtractedMessagesReturnsOldestOnesInReversedOrderOfAddition() {
        givenAnEmptyLane()
        sut.send(message: Message(types: ["first_test"], payload: nil))
        sut.send(message: Message(types: ["second_test"], payload: nil))
        sut.send(message: Message(types: ["third_test"], payload: nil))

        let messages = sut.extract(numberOfMessages: 3)

        XCTAssertEqual(messages.first?.types.first, "third_test")
        XCTAssertEqual(messages.last?.types.first, "first_test")
    }

    func testExtractedMessagesReturnsOldestOnesInOrderOfAddition() {
        givenAnEmptyLane()
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
        givenAnEmptyLane()
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
        givenAnEmptyLane()
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

    func givenAnEmptyLane() {
        self.sut = MessageBus()
    }

    func givenALane(withNumberOfMessages count: Int) {
        self.sut = MessageBus()
        let messages = (0..<count).map { Message(types: ["test_" + String($0)], payload: nil) }
        self.sut.send(messages: messages)
    }

    // MARK: Assert

    func assertEmptyLane() {
        XCTAssertEqual(sut.numberOfMessages, 0)
    }

    func assertLane(withNumberOfMessages count: Int) {
        XCTAssertEqual(sut.numberOfMessages, count)
    }
}
