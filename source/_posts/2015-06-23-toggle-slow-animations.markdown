---
layout: post
author: rafa
title: "Toggle Slow Animations"
date: 2015-06-23 22:36:49 +0200
comments: false
categories: 
---

iOS Simulator has a feature that slows animations, you can toggle it either by pressing `⌘T` or choosing `Debug > Toggle Slow Animations in Frontmost App`. It's very useful, but what if we want to do the same on device? It's easy, fast and simple.

`CALayer` has a property called `speed`, which is a time multiplier. This means that if we have an animation with a duration of 1 second, and set the layer's speed to 2, it'll take just 0.5 seconds to finish. The best thing about it is that it's related to the parent layer. So when we change the speed of a particular `CALayer`, every child layer will be affected. So, if we change `UIWindow` layer speed, every `CALayer` in our application will perform animations with that custom speed value. That leaves us with this two extensions:

``` swift
extension UIWindow {

    var slowAnimationsEnabled: Bool {
        get {
            return layer.speed != 1
        }
        set {
            layer.speed = newValue ? 0.2 : 1
        }
    }
}

extension UIApplication {

    func setSlowAnimationsEnabled(enabled: Bool) {
        windows.map({ window in (window as? UIWindow)?.slowAnimationsEnabled = enabled })
    }
}
```
And you can call it in both ways:

```swift
UIApplication.sharedApplication().keyWindow?.slowAnimationsEnabled = true
UIApplication.sharedApplication().setSlowAnimationsEnabled(true)
```

You can go further and expose this to your testers, through iOS Settings Bundle or a fancy shake gesture. Pretty handy!