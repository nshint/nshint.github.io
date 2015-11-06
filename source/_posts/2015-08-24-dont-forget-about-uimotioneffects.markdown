---
layout: post
title: "Don't forget about UIMottionEffect"
author: rafa
date: 2015-08-24 20:00:52 +0200
comments: false
categories:
---

`UIMotionEffects` was first introduced in iOS 7. The [WWDC session](https://developer.apple.com/videos/enterprise/#30) which presented this, amongst other cool things, is named Implementing Engaging UI on iOS. Nevertheless, `UIMotionEffects` is still overlooked. But not today, let's make something cool with it.

Motion effects is an easy way to react to external variations on the device's orientation. To say, `UIKit` performs UI changes whenever the user tilts the device, vertically or horizontally.

Let's use `UIInterpolatingMotionEffect` a subclass of `UIMotionEffects`, with `MapKit`. Notice how appealing it is.
<!--more-->
{% img center /images/dont-forget-about-motion-effects/01.gif %}

Sweet, right?

Achieving it, is easier than you think. Just a few lines of code and you're good to go:

```swift
var horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .TiltAlongHorizontalAxis)
horizontalMotionEffect.minimumRelativeValue = -100
horizontalMotionEffect.maximumRelativeValue = 100

mapView.addMotionEffect(horizontalMotionEffect)
```

Think of `minimumRelativeValue` and `maximumRelativeValue` as leading and tralling constraints, respectivily, to its `superview`.

That's why you have to create the `UIView`, `MKMapView` in this case, outside its `superview`s bounds. Like so:

{% img center /images/dont-forget-about-motion-effects/02.png %}


As the user tilts the device, `UIInterpolatingMotionEffect` translates the fixed offset values returned by the system to the range of specified values, then `UIKit` applies the translated values to any target views.


Don’t forget about this! Details matters and it's what users love in mobile apps!