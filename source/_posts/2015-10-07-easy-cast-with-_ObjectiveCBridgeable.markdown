---
layout: post
title: "Easy cast with _ObjectiveCBridgeable"
date: 2015-10-07 19:15:43 +0200
comments: true
author: rafa
categories:
---

Swift is out there for about a year and it's a great programming language. I think that almost every iOS/OSX developer out there has already written couple of things in Swift (if you haven't, go ahead and try, you won't regret it, I promise). Although, we have many years of libs and frameworks built using Objective-C and sooner or later a project may have both Swift and Objective-C working together.
<!--more-->
Fortunately, Apple gave us a [book](https://itunes.apple.com/us/book/using-swift-cocoa-objective/id888894773?mt=11) and a couple of WWDC session ([here](https://developer.apple.com/videos/play/wwdc2014-406/) and [here](https://developer.apple.com/videos/play/wwdc2015-401/)) with the intent to help developers on this task.

For those who have some experience with this integration knows that casting plays an important role. So, todays hint will dig into an poor documented protocol called `_ObjectiveCBridgeable`.

The documentation, which is only founded in header files says:

> A Swift Array or Dictionary of types conforming to _ObjectiveCBridgeable can be passed to Objective-C as an NSArray or NSDictionary, respectively. The elements of the resulting NSArray or NSDictionary will be the result of calling _bridgeToObjectiveC on each element of the source container.

Ok, but there is something else you can do with that, which is very handy.

Suppose that you have this class in Objective-C:

```objc
@interface OPerson: NSObject

- (instancetype)initWithName:(NSString *)name surname:(NSString *)surname;

@property (nonatomic, copy) (NSString *)name;
@property (nonatomic, copy) (NSString *)surname;

@end
```

Now you want to easily cast this class into a Swift struct. Yes, we can! All you have to do is conform to `_ObjectiveCBridgeable`, like so:

```swift
struct Person {
        let name: String
        let surname: String
}

extension Person: _ObjectiveCBridgeable {

    typealias _ObjectiveCType = OPerson

    static func _isBridgedToObjectiveC() -> Bool {
            return type
    }

    static func _getObjectiveCType() -> Any.Type {
            return ObjectiveCType.self
    }

    func _bridgeToObjectiveC() -> _ObjectiveCType {
            return OPerson(name: name, surname: surname)
    }

    static func _forceBridgeFromObjectiveC(source: _ObjectiveCType, inout result: Person?) {
            result = Person(name: source.name, surname: source.name)
    }

    static func _conditionallyBridgeFRomObjectiveC(source: _ObjectiveCType, inout result: Person?) -> Bool {
            _forceBridgeFromObjectiveC(source, result: &result)
            return true
    }
}
```

And voilá!

```swift

let objcPerson = OPerson(name: "John", surname: "Doe")

if let swiftPerson = objcPerson as? Person {
	//will work
}

let swiftPerson = objcPerson as Person //this too!

let swiftPerson2 = Person(name: "Jack", surname:"Doe")
let objcPerson = swiftPerson2 as OPerson //and that

let person: OPerson = Person(name: "Alfred", surname: "Doe") //hooray
```

Oh, that's so beautiful, don't you think? :]