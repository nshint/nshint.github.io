---
layout: post
title: "UITraitCollection trick"
date: 2015-09-23 19:15:43 +0200
comments: true
author: wojtek
categories:
---

Gone are the days where there was just one iPhone for developers as a target. Now we have to support multiple devices with different screen sizes. Fortunately, we have autolayout, which solves a part of this design equation, the other part is solved with [`UITraitCollection`](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITraitCollection_ClassReference/). Trait collection object has two size classes: horizontal and vertical. Each of these classes has three possible values: compact, regular or any. The current device+orientation can be described as a combination of the sizes.

{% img center /images/uitraitcollection_trick/1.png %}  

The best thing is that storyboards and nib files support these size classes. We can make layout changes directly onto them. Every view or auto-layout constraint can exist in one or several other size classes. So it is possible to support multiple devices and orientations without any code. Nevertheless there is a case, which is not covered at all. Imagine that you support only portrait mode and the designer wishes to make a difference between iPhone 5 and iPhone 6+ screen. In this case, size classes are not much helpful. However, we can leverage them in an unusual way.

`UITraitEnvironment` is a protocol which provides access to trait collection. Its conformed by most of the objects in view hierarchy: `UIScreen`, `UIWindow`, `UIViewController`, `UIView`. Every child inherits the trait collection object from its parent. The trick is to override the trait collection in `UIWindow` and return a custom value for iPhone 6+ device. Take a look:

```swift
@objc public class Window: UIWindow {

    override public var traitCollection: UITraitCollection {

        if DeviceType.isIPhone6P {

            var collections = [UITraitCollection(horizontalSizeClass: .Compact),
                UITraitCollection(verticalSizeClass: .Compact)]

            return UITraitCollection(traitsFromCollections: collections)
        }

        return super.traitCollection
    }
}
```

We override trait collection in `UIWindow` just for iPhone 6+ model. Now we can make layout changes in storyboard directly for this model by changing size class selectors at the bottom of Interface Builder pane. Trait collection with horizontal compact class and vertical compact class is reserved for iPhone 6+.

{% img center /images/uitraitcollection_trick/2.png %}  

We can install additional views and change layout constraints only for iPhone 6+.

{% img center /images/uitraitcollection_trick/3.png %}  
{% img center /images/uitraitcollection_trick/4.png %}  

Tell your designer about that cool hint and you will probably get some treats. The project shown above can be found on [GitHub](https://github.com/nshintio/uitraitcollection-trick).
