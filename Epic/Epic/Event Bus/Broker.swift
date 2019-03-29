/**
 Provides base implementation for any sub-broker class.

 # Do not create instances of this class directly. Use a subclass instead.

 # Purpose
 A broker should choose a lane from which it will extract messages continuously.
 Use the init method for this purpose.
 You won't be able to alter the lane or the polling load once the broker starts gathering messages.

 # Performance
 Configure `pollingLoad` and `pollingTime` to your specific needs, since they will have a huge impact on your code performance.
 There is no limit for the amount of messages you can deal with at a time.
 */
open class Broker {
    /// Message Bus used to retrieve messages
    public let messageBus: MessageBusProtocol
    /// Number of items retrieved on every fetch
    public let pollingLoad: Int
    /// Interval of seconds between fetches
    public var pollingTime: TimeInterval
    /// Returns whether the broker is currently fetching messages
    public var fetching: Bool { return isFetchingData }
    private var isFetchingData: Bool = false

    public typealias OnFetchClosure = (([Message]) -> Void)
    private var onFetch: OnFetchClosure?

    /**
     Creates a Broker instance using a given message bus as input source.

     - Parameters:
        - messageBus: Any object that complies to MessageBusProtocol.
        - pollingLoad: Number of messages collected at a time. It will affect your code performance.
        - pollingTime: Amount of time between message fetches. It will affect your code performance.
    */
    public init(messageBus: MessageBusProtocol, pollingLoad: Int = 1, pollingTime: TimeInterval = 5) {
        self.messageBus = messageBus
        self.pollingLoad = pollingLoad
        self.pollingTime = pollingTime
    }

    /// Starts fetching messages
    /// You can start retrieveing messages if you implement the trailing closure.
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
            let messages = self.messageBus.extract(numberOfMessages: self.pollingLoad)
            self.fetch(messages: messages)
            if let onFetchClosure = self.onFetch { onFetchClosure(messages) }
        })
    }()

    /// Messages retrieved from the Message Bus
    /// Override this method to listen to substracted messages.
    open func fetch(messages: [Epic.Message]) {}

    deinit {
        self.stop()
    }
}
