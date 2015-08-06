---
layout: post
title: "Law Of Demeter"
date: 2015-08-03 13:24:06 +0200
comments: false
author: rafa
categories:
---
You may haven't heard about this law or if you have, you may have wondered [who's this Demeter guy](http://homepages.cwi.nl/~storm/teaching/reader/LieberherrHolland89.pdf). Regardless of it, the Law Of Demeter (LoD) is a foundation concept that's used among several design patterns, to wit: Delegate, Proxy, Façade, Adapter and Decorator. Therefore, you probably are already taking advantage of this Law, knowing it or not.

There's a particular situation that occurs with iOS, that's perfect for applying the LoD. Sometimes it's needed to call method in our `UIApplicationDelegate`. The common way of doing that is the following:

```swift
let sharedApplication = UIApplication.sharedApplication()
let delegate = sharedApplication.delegate
if let delegate = delegate as? AppDelegate {
    delegate.doSomething()
}
```
There are too many temporary objects, and presumably, there's no reason why this class should know about `AppDelegate` casting and so on.

Using the `Decorator` pattern, is a way to wrap up this logic and decouple stuff.

```swift
extension UIApplication {
    class func myDelegate() -> AppDelegate {
        return (self.sharedApplication().delegate as! AppDelegate)
    }
    class func doSomething() {
        myDelegate().doSomething()
    }
}

extension AppDelegate {
    class func doSomething() {
        UIApplication.doSomething()
    }
}
```

Now the class would just call `UIApplication.doSomething()` or `AppDelegate.doSomething()`.

Another situation that's a claimer for LoD is when you have chained 'get' statements, for example:

```swift
let myDesire = Metallica().gimmeFuel().gimmeFire().gimmeThatWhichIDesire()
``

In such a case, the `Metallica` class should be refactored and provide it with a mean of calling `Metallica().gimmeThatWhichIDesire()`, for example:

```swift
class Metallica {
    func fuelSetOnFire(fuel: Fuel) -> Fire {
    	return Fire.setFuelOnFire(fuel)
    }
    
    func gimmeThatWhichIDesire() -> Desire {
        return Desire.fromFire(fuelSetOnFire(metallicasFuel))
    }
}
```

Wrapping up method calls, separating concerns and decoupling classes are the spine of LoD. Some can say that objects become more complex, but one thing is for sure, your software components will be more testable, and that is a big win!

Now go ahead and follow the rule!
