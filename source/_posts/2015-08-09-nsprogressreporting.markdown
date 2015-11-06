---
layout: post
title: "NSProgressReporting"
author: matt
date: 2015-08-09 20:00:52 +0200
comments: false
categories: 
---

In iOS7 and OS X 10.9 Apple released NSProgess. Its a nice, helpful piece of code that was supposed to make our coding lifes easier.
If you finally [find a proper way to use it](http://oleb.net/blog/2014/03/nsprogress/) it can be very beneficial.

Besides of helpfull UserInfo object keys which give us comprehensive text information about progress of our tasks in proper language, NSProgress was supposed to provide us way of compositioning objects into trees. However, first version of class allowed this in an implicit way which does not look very clear first time you learn it.
<!--more-->
I will try to present it to you in a short way:
```swift
let parentProgress = NSProgress()
parentProgress.totalUnitCount = 2
parentProgress.becomeCurrentWithPendingUnitCount(1)

let childProgress = NSProgress(totalUnitCount:1)
parentProgress.resignCurrent()
```
When applying this approach you have to create child progress using totalUnitCount convenience constructor immediately. You also should document that you support implicit composition in a clear way.

OSX 10.11 and iOS 9.0 provides more explicit way for creating tree structure of NSProgress objects. Things are simple now:
```swift
let parentProgress = NSProgress()
let childProgress = NSProgress()
parentProgress.addChild(childProgress, withPendingUnitCount:1)
```

There is also one more thing useful thing in process of forwarding progress through our app architecture. When any of your classes is free to attend in NSProgress family tree, simply implement following protocol:
```swift
protocol NSProgressReporting : NSObjectProtocol {
    var progress: NSProgress { get }
}
```
This way we are able to easily track progress of tree structure of tasks and get our overall progress in an easy, object oriented way.
