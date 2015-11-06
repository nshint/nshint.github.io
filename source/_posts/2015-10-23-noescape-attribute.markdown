---
layout: post
author: matt
title: "@noescape attribute"
date: 2015-10-23 17:00:00 +0200
comments: false
categories: 
---

Swift 1.2 introduced us with `@noescape` attribute. It's a very important feature, when we want to make our code more cleaner and stricter. Using it properly at 3am will prevent many unwanted retain cycles.

While digging into [release notes](https://developer.apple.com/library/ios/releasenotes/DeveloperTools/RN-Xcode/Chapters/xc6_release_notes.html) we can see a bunch of clever words:
> A new `@noescape` attribute may be used on closure parameters to functions. This indicates that the parameter is only ever called (or passed as an @noescape parameter in a call), which means that it cannot outlive the lifetime of the call. This enables some minor performance optimizations, but more importantly disables the `self.` requirement in closure arguments.
<!--more-->
Lets analyze those smart statements and put it into code so everyone can enjoy it: 

```swift
func foo(@noescape code:(() -> String)) -> String
{
    return "foo \(bar(code))"
}

func bar(@noescape code:(() -> String)) -> String
{
    return code() 
}

print(foo() {"bar"})
```

It can be also captured in another `@noescape` closure:

```swift
func baz(@noescape code:(() -> String))
{
    qux {
        code()
    }
}
func qux(@noescape code:(() -> String)) {}
```

It's important to point out, that closures (and functions) annotated with `@noescape` can only be passed as `@noescape` parameters. What this mean is:

* we cannot run it asynchronously:
{% img center /images/noescape-attribute/noescape-async.png %}
* we can't store it
{% img center /images/noescape-attribute/noescape-store.png %}
* we can't capture it in another non-`@noescape` closure
{% img center /images/noescape-attribute/noescape-capture.png %}

Last to mention, in the future releases this will be taken even further:

> This enables control-flow-like functions to be more transparent about their behavior. In a future beta, the standard library will adopt this attribute in functions like autoreleasepool().
```swift
func autoreleasepool(@noescape code: () -> ()) {
    pushAutoreleasePool()
    code()
    popAutoreleasePool()
}
```
So dear developer the best is yet to come! ;]
