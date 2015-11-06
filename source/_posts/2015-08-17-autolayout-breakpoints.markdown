---
layout: post
title: "Autolayout breakpoints"
author: rafa
date: 2015-08-17 20:00:52 +0200
comments: false
categories:
---

Auto layout has become a crucial tool for iOS and OS X development. It makes creating layout for multiple screen sizes easy peasy. But sometimes it can drive you crazy, with verbose and misleading logs.
<!--more-->
```
Unable to simultaneously satisfy constraints.
Probably at least one of the constraints in the following list is one you don't want.
Try this:

(1) look at each constraint and try to figure out which you don't expect;
(2) find the code that added the unwanted constraint or constraints and fix it.
(Note: If you're seeing NSAutoresizingMaskLayoutConstraints that you don't understand, refer to the documentation for the UIView property translatesAutoresizingMaskIntoConstraints)

(...........)


Make a symbolic breakpoint at UIViewAlertForUnsatisfiableConstraints to catch this in the debugger.
The methods in the UIConstraintBasedLayoutDebugging category on UIView listed in <UIKit/UIView.h> may also be helpful.
```

That's a huge log! And I cut off the `NSLayoutConstraint` part. Yet, the second last line is giving a clue in which direction to go to fix this issue. Symbolic breakpoint at `UIViewAlertForUnsatisfiableConstraints`.

All right, here's what Xcode want's you to do:

{% img center /images/autolayout-breakpoints/1.png %}

Honestly, that won't help much, because basically it'll just stop the execution and leave you up with `LLDB`, alone in the dark.

But there's a little trick you can do to enhance the preceding symbolic breakpoint.
Adding `po [[UIWindow keyWindow] _autolayoutTrace]` to it (for Obj-C projects) or `expr -l objc++ -O -- [[UIWindow keyWindow] _autolayoutTrace]` (for Swift projects).

{% img center /images/autolayout-breakpoints/2.png %}

Now, on console, you'll see all the `UIView` hierarchy and exactly where it has ambiguity.

```objc
UIWindow:0x7f9481c93360
|   •UIView:0x7f9481c9d680
|   |   *UIView:0x7f9481c9d990- AMBIGUOUS LAYOUT for UIView:0x7f9481c9d990.minX{id: 13}, UIView:0x7f9481c9d990.minY{id: 16}
|   |   *_UILayoutGuide:0x7f9481c9e160- AMBIGUOUS LAYOUT for _UILayoutGuide:0x7f9481c9e160.minY{id: 17}
|   |   *_UILayoutGuide:0x7f9481c9ebb0- AMBIGUOUS LAYOUT for _UILayoutGuide:0x7f9481c9ebb0.minY{id: 27}
```

Note that as you hit continue it'll stop at every ambiguous layout you may have.
And if that's not enough for you to find out your autolayout issue, try changing the view's color, who knows?

```objc
(lldb) expr ((UIView *)0x7f9ea3d43410).backgroundColor = [UIColor redColor]
(UICachedDeviceRGBColor *) $1 = 0x00007f9ea3d43410
```

Fear no more young Padawan, make symbolic breakpoints and `LLDB` work for you!

I would like to thank [Porter Hoskins](https://twitter.com/PorterHoskins) for pointing out the correct `LLDB` command for Swift.