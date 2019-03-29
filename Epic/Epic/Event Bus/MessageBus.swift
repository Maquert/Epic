/// Represents a basic MessageBus contract with Epic
public protocol MessageBusProtocol {
    func send(message: Message)
    func send(messages: [Message])
    func extract(numberOfMessages: Int) -> [Message]
}

public extension MessageBusProtocol {
    /// Adds one message to the queue
    func send(message: Message) {
        self.send(messages: [message])
    }
}

/**
 Stores and drops messages in a FIFO fashion

 Use `send(message:)` to append messages to the queue`
 Use `extract(numberOfMessages:)` to drop messages from the queue.
*/
 public class MessageBus: MessageBusProtocol {
    private var messageQueue = [Message]()

    public init() {}

    /// Returns a message from the queue
    public subscript(index: Int) -> Message? {
        guard (0..<self.messageQueue.count).contains(index) else { return nil }
        return self.messageQueue[index]
    }

    /// Returns the pending number of messages in the queue
    public var numberOfMessages: Int { return self.messageQueue.count }

    /// Adds message(s) to the queue
    public func send(messages: [Message]) {
        let sortedMessages = messages.reversed()
        self.messageQueue.insert(contentsOf: sortedMessages, at: 0)
    }

    /// Returns a number of messages in the FIFO style.
    /// Retrieved messages are deleted after this operation.
    public func extract(numberOfMessages: Int = 1) -> [Message] {
        let lastMessages = Array(self.messageQueue.suffix(numberOfMessages))

        self.messageQueue = Array(self.messageQueue.dropLast(numberOfMessages))
        return lastMessages
    }
}

/// Message values are stored and dispatched through the Epic Lane object
///
/// Messages are typically created with a type value.
/// A payload can be attached with further data
public struct Message {
    public typealias MessageType = String
    public typealias PayloadType = [String: Any]

    public let types: [MessageType]
    public let payload: PayloadType?

    public init(types: [MessageType], payload: PayloadType?) {
        self.types = types
        self.payload = payload
    }
}
