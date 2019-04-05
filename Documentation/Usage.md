# Usage

## Package
```swift
import Epic
```

## Throttle

### Problem

My application is processing loads of repeated or incremented amounts of data in a very short amount of time.

For instance, a network request that is sent to the backend every time the user types a new character. Probably, sending a request for all 20 keystrokes is underperformant.

### Solution

Regulate how many outbound processes are actually dispatched to the network by setting a specific amount of time between them.

That is: if the user types 5 times in half a second, only make a request for the first and the last keystrokes in that window of time.

### Implementation

Declare a single **Throttle** instance to balance your calls and set the time interval in seconds:
```swift
let throttler = Throttle(interval: 0.5)
```
*Unless specified, the Throttle initialises with 1 second. You may adjust the time interval to your needs.*

Move your throttable method inside the `throttle` closure:
```swift
func sendNetworkRequest(query) {
    self.throttler.throttle { 
        API.performRequest(..., query)
    }
}
```

## Generator

### Problem

My application is constantly executing many operations and it's hard to track what and when is being processed at any given time. The code is hard to read and understand because many of these operations are spreaded around and some may have dependencies on others.

I wish I could easily enumerate and then execute them from one single place.

### Solution

Declare all your operations as you would declare an array of tasks. Then use a **Generator** to dispatch them one by one (or all at once).

The Swift language already provides us with protocols to accomplish this. The `Epic.Generator` is an abstraction, ready for consumption.

A **Generator** is just another kind of *iterator*, as `for each` or `while`, for instance. This version simply takes an array and yields the values one at a time.

### Implementation

Declare your operations. Of course, these could be dynamically created.

```swift
let initialOperations = [
    Operation("app.open.home_screen", block: { ... }),
    Operation("app.fetch.user_data", block: { ... }),
    Operation("app.populate.home_screen", block: { ... }),
]
```
*All operations require a name*.

```swift
let generator = Generator(operations: initialOperations)
```

If you want a step by step control over your operations, get the iterator instance and then call `next()` to get the first task.

```swift
var iterator = generator.iterator()
let firstOperation = iterator.next()
// It returns the next operation
```

Alternativelly, you may want to execute the block immediately.
```swift
iterator.next(executingBlock: true) 
// It executes the next operation and then returns it to you. You can of course discard the result, as in the example above.
```

Consecutive calls to `next()` or `next(executingBlock: Bool)` will return following operations until no operations remain. Once finished, further calls to `next()` will do nothing.

You may check if the generator has already executed all the operations with `iterator.finished`. Additionally, you can use the `lastIndex` attribute to check the last position that was executed.


### Run all tasks at once
Operations can be all dispatched automatically, in a sequential manner.

In order to achieve this, just call `run()` directly on the generator.
```swift
generator.run()
```

Beware that asynchronous tasks are dispatched in sequence, but they may finish in a different order due to its undetermined nature. You cannot declare dependencies between them, so reacting to their respective completions is up to you.

If you need to know whether all your operations were dispatched (it does not always imply *finished* for async operations) you may use the same iterator instance, as explained above. 

Just get the iterator from the `run()` method, as in `let iterator = generator.run()`.