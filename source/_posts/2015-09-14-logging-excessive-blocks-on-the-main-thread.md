---
layout: post
title: "Logging excessive blocks on the main thread"
date: 2015-09-14 01:30:09 +0200
comments: true
author: rafa
categories:
---
Logging excessive blocks on the main thread

Having an application running at 60 FPS is every programmers dream, and users delight.
The worst users experience ever is a frozen and unresponsive screen. It's a dreadful crime in mobile world nowadays. Users try to interact at any moment and according to Murphy’s law they will find all your mistakes. So, you better keep the main thread slim.

To keep things smoothly in the users interface, every single operation that's schedule to run into the main thread can take longer than 16 milliseconds, and there's a handy solution to get you covered. It's a little library called [Watchdog](https://github.com/wojteklukaszuk/Watchdog).

Watchdog is a very simple and straightforward library that logs excessive blocking on the main thread. Let's take a look at how to use it:

```swift
let watchdog = Watchdog(0.2)
```

Just instantiate it with a number of seconds that you want for Watchdog to consider that the main thread blocked. Also don't forget to retain Watchdog somewhere or it will get released when it goes out of scope. Whenever the main thread is blocked for more than the value previously defined, it will print out logs, just like this:

```
👮 Main thread was blocked for 1.25s 👮
```

Pretty nice debugging tool!