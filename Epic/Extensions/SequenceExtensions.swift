//
//  SequenceExtensions.swift
//  Epic
//
//  Created by Miguel Hernández Jaso on 20/02/2019.
//  Copyright © 2019 Miguel Hernández Jaso. All rights reserved.
//

extension Sequence where Self: Collection {
    /// Returns an array containing, in order, the elements of the sequence that satisfy the given predicates
    public func filter(with filterClosures: [(Self.Element) -> Bool]) -> [Self.Element] {
        return self.flatFilter(collection: Array(self), filterClosures: filterClosures)
    }

    private func flatFilter(collection: [Self.Element], filterClosures: [(Self.Element) -> Bool]) -> [Self.Element] {
        guard filterClosures.count > 0, collection.count > 0 else { return collection }
        let (firstFilter, filters) = headTail(collection: filterClosures)
        guard let filter = firstFilter else { return collection }
        let filteredCollection = collection.filter(filter)
        return self.flatFilter(collection: filteredCollection, filterClosures: filters)
    }
}

extension Sequence {
    /// Returns the first element in the array and the remaining elements
    public func headTail<T>(collection: [T]) -> (T?, [T]) {
        guard let filter = collection.first else { return (nil, collection) }
        let filters = collection.dropFirst()
        return (filter, Array(filters))
    }
}
