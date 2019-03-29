/// Represents a container that stores all items for a related topic
public protocol Topic {
    var name: String { get }
    var messages: [Epic.Message] { get set }
    var lastIndex: Int { get set }

    /// Adds new messages. Messages are not destroyed.
    mutating func store(messages: [Epic.Message])
}

public extension Topic {
    /// Stores new messages
    /// Last index value represents the position between the last older message was retrieved
    public mutating func store(messages: [Epic.Message]) {
        self.lastIndex = self.messages.count
        self.messages.append(contentsOf: messages)
    }

    /// Returns the last added messages
    public var newMessages: [Epic.Message] {
        guard self.lastIndex > 0 else { return self.messages }
        let newItems = self.messages.dropFirst(self.lastIndex)
        return Array(newItems)
    }

    /// Cleans the oldest messages, based on the last index value
    public mutating func purge() -> [Epic.Message] {
        self.messages = Array(self.messages.dropLast(self.lastIndex))
        self.lastIndex = self.messages.count
        return self.messages
    }
}
