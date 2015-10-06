---
layout: post
title: "Easy cast with _ObjectiveCBridgeable"
date: 2015-10-07 19:15:43 +0200
comments: true
author: rafa
categories:
---

Swift is out there for about a year, and it's a great programming language. I think that almost every iOS/OSX developer out there has already written couple of things in Swift (you you haven't, go ahead and try, you won't regret, I promise). Although, we have many years of libs and frameworks built using Objective-C and sooner or later a project may have both Swift and Objective-C working together.

Fortunately, Apple gave us a [book](https://itunes.apple.com/us/book/using-swift-cocoa-objective/id888894773?mt=11) and a couple of WWDC session ([here](https://developer.apple.com/videos/play/wwdc2014-406/) and [here](https://developer.apple.com/videos/play/wwdc2015-401/)) with the intent to help developers on this task.

For those who have some experience with this integration knows that casting plays an important role. So, todays hint will dig into an poor documented protocol called `_ObjectiveCBridgeable`.

The documentation, which is only founded in header files says:

> A Swift Array or Dictionary of types conforming to _ObjectiveCBridgeable can be passed to Objective-C as an NSArray or NSDictionary, respectively. The elements of the resulting NSArray or NSDictionary will be the result of calling _bridgeToObjectiveC on each elmeent of the source container.

Ok, but there is something else you can do with that, which is very handy.

Suppose that you have this class in Objective-C:

```objc
@interface OPoint: NSObject

- (instancetype)initWithX:(double)x y:(double)y;

@property double x;
@property double y;

@end
```

Now you want to easily cast this class into a Swift struct. Yes, we can! All you have to do is conform to `_ObjectiveCBridgeable`, like so:

```swift
extension Point: _ObjectiveCBridgeable {

    typealias _ObjectiveCType = OPoint

    static func _isBridgedToObjectiveC() -> Bool {
            return type
    }

    static func _getObjectiveCType() -> Any.Type {
            return ObjectiveCType.self
    }

    func _bridgeToObjectiveC() -> _ObjectiveCType {
            return OPoint(x: x, y: y)
    }

    static func _forceBridgeFromObjectiveC(source: _ObjectiveCType, inout result: Point?) {
            result = Point(x: source.x, y: source.y)
    }

    static func _conditionallyBridgeFRomObjectiveC(source: _ObjectiveCType, inout result: Point?) -> Bool {
            _forceBridgeFromObjectiveC(source, result: &result)
            return true
    }
}
```

And voilá!

```swift

let objcPoint = OPoint(x: 0, y: 2)

if let swiftPoint = objcPoint as? Point {
	//will work
}

let swiftPoint = objcPoint as Point //this too!

let swiftPoint2 = Point(x:5, y:10)
let objcPoint2 = swiftPoint2 as OPoint //and that

let point: OPoint = Point(x: 1, y: 1) //hooray
```

Oh, that's so beautiful, don't you think? :]