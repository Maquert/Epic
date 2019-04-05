# Extensions

## Package
```swift
import Epic
```

## Filter
*With an array of predicates*

The Swift language provides a high order function called `filter` that returns a copy of the same array only with the elements that satisfy a given predicate.

```swift
let cast = ["Vivien", "Marlon", "Kim", "Karl"]
let shortNames = cast.filter { $0.count < 5 }
print(shortNames)
// Prints "["Kim", "Karl"]"
```
*[From Apple Docs](https://developer.apple.com/documentation/swift/sequence/3018365-filter)*

**But, what if you want to apply more than one filter?**

For instance:
```swift
let fourAndFiveLetterNames = cast.filter { $0.count < 6 && $0.count > 3 }
print(fourAndFiveLetterNames)
// Well, it still Prints "["Karl"]"
```

You can achieve this by adding more rules to the filter. For this kind of situation it may be ok to add the AND operator:
- Values are simple (they are String types).
- Both operations retrieve the value from the same attribute (in this case, the value itself).
- It's easy to understand because we see the sequence above and applying a couple of conditions can be mentally computed.

 For other kind of sequences, it may be a bit complicated and overwhelming to understand. Say that we have an undetermined array of users:
```swift
let users = [user1, user2, user3, ...]
```

Now, we want to apply various filters so we get only the ones that satisfy some given predicates. We could of course apply those filters line by line.

```swift
let goldUsers = users.filter { $0.subscription.isGold }
let singleUsers = users.filter { $0.personalInfo?.partner == null }
```

And so on.

Now, what if those predicates are **not** static? Imagine they could change depending on the situation. We would have to add multiple filtering instances, right?

**I would be nice for `filter` to accept an array of predicates**. This is what `filter(with: [(Element) -> Bool])` does.

```swift
let rules = [
    { $0.isGold },
    { $0.personalInfo?.partner == null }
]
let result = users.filter(with: rules)
```

The order of the filters is respected, so if you apply a very aggressive filter in the first position, the following arrays of operations will be significantly shorter.

#### Considerations

*`filter(with:)` only works on the Sequence type* 