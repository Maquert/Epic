/**
 Protocols provide an easy interface to swap Epic objects with your own.
 */

public protocol GeneratorProtocol {
    associatedtype IteratorType
    init(operations: [Operation])

    func iterator() -> IteratorType
    func run() -> IteratorType
}

public protocol IteratorProtocol: Swift.IteratorProtocol {
    var lastIndex: Int { get }
    var finished: Bool { get }

    mutating func next() -> Operation?
    mutating func next(executingBlock: Bool) -> Operation?
}

public protocol OperationProtocol {
    var identifier: String { get }
    var block: EpicBlock? { get }
    init(_ identifier: String, block: EpicBlock)
}
