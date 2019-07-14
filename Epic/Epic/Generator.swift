/// Performs a sequence of operations
/// - Use `iterator()` for a step-by-step run
/// - Use `run()` to execute all tasks one by one. Asynchrony is not handled and tasks may be parallelised.
public struct Generator {
    let operations: [Operation]
    public init(operations: [Operation]) {
        self.operations = operations
    }

    public func iterator() -> Iterator {
        return Iterator(self)
    }

    /// Runs all operations and executes their blocks.
    /// Returns the iterator.
    public func run() -> Iterator {
        var iterator = self.iterator()
        while iterator.finished == false {
            let operation = iterator.next()
            if let block = operation?.block {
                block()
            }
        }
        return iterator
    }

    public struct Iterator {
        private let generator: Generator
        private var currentIndex: Int = 0
        public var lastIndex: Int { return currentIndex }
        /// Returns true if there are no more operations to follow
        public var finished: Bool { return (self[self.currentIndex]) == nil ? true : false }

        init(_ generator: Generator) {
            self.generator = generator
        }

        /// Returns the next operation to be executed
        @discardableResult
        public mutating func next() -> Operation? {
            guard let nextItem = self[self.currentIndex] else { return nil }

            self.currentIndex += 1
            return nextItem
        }

        /// Returns the next operation and also executes its block automatically
        @discardableResult
        public mutating func next(executingBlock: Bool) -> Operation? {
            let operation = self.next()
            if executingBlock == true, let block = operation?.block { block() }
            return operation
        }

        private subscript(index: Int) -> Operation? {
            guard (0..<self.generator.operations.count).contains(index) else { return nil }
            return self.generator.operations[index]
        }
    }
}

/// A single operation to be dispatched in the Generator.
///
/// An Epic block is a no-return closure
public struct Operation {
    public let identifier: String
    public let block: EpicBlock?

    public init(_ identifier: String, block: EpicBlock?) {
        self.identifier = identifier
        self.block = block
    }
}
