//
//  Broker.swift
//  Epic
//
//  Created by Miguel Hernández Jaso on 01/03/2019.
//  Copyright © 2019 Miguel Hernández Jaso. All rights reserved.
//

import Foundation

open class Broker {
    /// Lane used to retrieve messages
    public let lane: MessageBusProtocol
    /// Number of items retrieved on every fetch
    public let pollingLoad: Int
    /// Interval of seconds between fetches
    public var pollingTime: TimeInterval
    /// Returns whether the broker is currently fetching messages
    public var fetching: Bool { return isFetchingData }
    private var isFetchingData: Bool = false

    public typealias OnFetchClosure = (([Message]) -> Void)
    private var onFetch: OnFetchClosure?

    public init(lane: MessageBusProtocol, pollingLoad: Int = 1, pollingTime: TimeInterval = 5) {
        self.lane = lane
        self.pollingLoad = pollingLoad
        self.pollingTime = pollingTime
    }

    /// Starts fetching messages
    public func subscribe(onFetch: OnFetchClosure? = nil) {
        self.onFetch = onFetch
        self.timer.fire()
        self.isFetchingData = true
    }

    /// Stops fetching messages.
    /// The broker won't be able to restart fetching messages.
    public func stop() {
        self.timer.invalidate()
        self.isFetchingData = false
    }

    private lazy var timer: Timer = {
        return Timer.scheduledTimer(withTimeInterval: self.pollingTime, repeats: true, block: { [weak self] (timer) in
            guard let `self` = self else { return }
            let messages = self.lane.extract(numberOfMessages: self.pollingLoad)
            self.fetch(messages: messages)
            if let onFetchClosure = self.onFetch { onFetchClosure(messages) }
        })
    }()

    open func fetch(messages: [Epic.Message]) {}

    deinit {
        self.stop()
    }
}
