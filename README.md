![Epic: Simple operations manager in Swift](https://github.com/maquert/Epic/blob/master/epic.png)

[![Build Status](https://travis-ci.org/Maquert/Epic.svg?branch=master)](https://travis-ci.org/Maquert/Epic)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Licence](https://img.shields.io/badge/licence-MIT-green.svg)](https://github.com/Maquert/Epic/blob/master/LICENSE)
[![Last commit](https://img.shields.io/github/last-commit/Maquert/Epic.svg)](https://github.com/Maquert/Epic/commits/master)
![Platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg?longCache=true&style=flat)
![Languages](https://img.shields.io/badge/languages-Swift-orange.svg?longCache=true&style=flat)
[![Twitter](https://img.shields.io/badge/twitter-@Maquert-blue.svg?style=flat)](https://twitter.com/Maquert)

# Epic

Epic is a simple operations manager written in Swift.

- [Features](#features)
- [Installation](#installation)
- [Feature Usage](https://github.com/maquert/Epic/blob/master/Documentation/Usage.md)
- [Extensions](https://github.com/maquert/Epic/blob/master/Documentation/Extensions.md)

## Features

- [x] Throttle
- [x] Generator
- [x] MessageBus

### Throttle

The Throttle regulates how many executions can get through the same bottleneck within a given amount of time.

```swift
let throttler = Throttle(interval: 0.2)

...
/// 5 calls to the throttle block
throttler.throttle {
    API.shared.makeRequest(...) // Just 2 came through
}
```

*It prevents overloads on potentially repetitive and intensive calls to a limited resource, and thus these calls will not degrade the performance of the whole system.*

For further documentation, [check the docs](https://github.com/maquert/Epic/blob/master/Documentation/Usage.md#Throttle).

### Generator

The Generator supplies block operations of a sequence one at a time.

It complies to Swift's [IteratorProtocol](https://developer.apple.com/documentation/swift/iteratorprotocol).

```swift
let generator = Generator(operations: [
    Operation("app.open.home_screen", block: { ... }),
    Operation("app.fetch.user_data", block: { ... }),
    Operation("app.populate.home_screen", block: { ... }),
])
var iterator = generator.iterator()
iterator.next(executingBlock: true) 
````

For further documentation, [check the docs](https://github.com/maquert/Epic/blob/master/Documentation/Usage.md#Generator).


### Message Bus

The MessageBus is a single entry for all your broadcast messages within your application.

It provides support for brokers and topics through protocols, so you can also inter-operate with your own.

By using a MessageBus all of your messages have the same structure (type and payload). Only the subscribed recipients are able to retrieve the right information for their purposes. 

```swift
static let messageBus = MessageBus()

messageBus.send(messages: [
    Message(types: ["analytics"], payload: [:...]})
    Message(types: ["user_event", "debug"], payload: [:...])
])
```

For further documentation, [check the docs (Documentation in Progress)](https://github.com/maquert/Epic/blob/master/Documentation/Usage.md#MessageBus).

### Extensions

Currently, only one extension over Sequence is included in Epic.

- [x] [Filter with an array of predicates](https://github.com/maquert/Epic/blob/master/Documentation/Extensions.md#Filter).

For further documentation, [check the docs](https://github.com/maquert/Epic/blob/master/Documentation/Extensions.md).

## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate Epic into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "Maquert/Epic" "0.1.0"
```

### Use
```swift
import Epic
```
