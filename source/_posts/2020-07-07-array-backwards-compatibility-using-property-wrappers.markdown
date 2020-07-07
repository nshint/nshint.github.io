---
layout: post
author: matt
title: "Array backwards compatibility using Property Wrappers"
date: 2020-07-07 14:19:05 +0200
comments: true
categories: 
---

Let's assume that you're doing an application which shows your users pretty pictures of seasons. You contact your backend folks and they tell you that the world is simple, there are only three seasons:

```swift
enum Season: String, Decodable {
    case spring, summer, autumn
}
```
<!--more-->

In order to compose things nicely, you put the seasons into a struct:

```swift
struct Seasons: Decodable {
    var available: [Season]
}
```

The following JSON comes from the server, it gets decoded, everything works well:
```json
"available": ["spring", "summer", "autumn"]
// [__lldb_expr_12.Season.spring, __lldb_expr_12.Season.summer, __lldb_expr_12.Season.autumn]
```

The application gets released. Time passes, winter comes and the app gets updated available seasons from the backend:
```json
"available": ["spring", "summer", "autumn", "winter"]
```

What happens now? Your functionality breaks.  
Since the app can't understand `Season.winter`, no seasons get decoded. You receive a lot of bug reports, and your users are not happy ☹️

If only there was something we could do to prevent this from happening..  
This seems like a nice use case for property wrappers!

```swift
@propertyWrapper
struct IgnoreUnknown<Value: Decodable>: Decodable {
    var wrappedValue: [Value]

    private struct Empty: Decodable {}

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.wrappedValue = []
        while !container.isAtEnd {
            do {
                wrappedValue.append(try container.decode(Value.self))
            } catch {
                _ = try? container.decode(Empty.self)
            }
        }
    }
}
```

This way, we simply add `@IgnoreUnknown` before our available seasons and voilà! After that, the `available` array simply skips the values it cannot understand 🚀
```swift
struct Seasons: Decodable {
    @IgnoreUnknown
    var available: [Season]
}
```

Property Wrappers come with a lot of other great use cases. Please see [Properties](https://docs.swift.org/swift-book/LanguageGuide/Properties.html) in Apple documentation for more details 🙂

Hope this blogpost was helpful, thanks for reading!
