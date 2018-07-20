---
layout: post
author: rafa
title: "Optional protocol methods without @objc"
date: 2016-08-21 22:36:49 +0200
comments: false
categories: 
---

Yesterday I was watching a [talk](https://realm.io/news/altconf-nikita-lutsenko-objc-swift-interoperability/) from Nikita Lutsenko about Swift and Objective-C Interoperability. At some point he states:

>
What Objective-C protocols are in Swift is very special. There is so much that was added specifically for it. It’s also weaker and not Swift-y, even though you can use `optional`. So, `optional` is not supported on Swift protocols, unless they are exported into Objective-C, because that time, they become Objective-C protocols.
There is also no ability to talk to extensions of these protocols. Either they are concrete extensions, with no way you can talk to a protocol and build things like protocol extensions, which we all love and use in Swift. So they’re very limited altogether.
If you actually are writing Swift code, please don’t use these, they make everyone’s life bad as well as they could not be used, say, in a Linux environment, where you don’t have Objective-C runtime.

<!--more-->
He's right! When you annotate a protocol with `@objc`, LLVM will generate a bunch of extra things: an `isa` pointer, runtime sections like: `__objc_imageinfo`, `__objc_classref`, etc. It seems that it's casting the protocol into a `NSObject`, and maybe it will have a performance penalty. Also `@objc` protocols can not be used with struct and enums, just class types.

The following assembly is for `@objc protocol`:

```llvm
                                       ; 
                                       ; @protocol _TtP9Protocols8Protocol_ {
                                       ;     -method
                                       ; }
00000001002afcb0                                 dq         0x0                 ; isa, XREF=0x1002abaa0, 0x1002b03c8
00000001002afcb8                                 dq         0x1002782f0         ; name, "_TtP9Protocols8Protocol_"
00000001002afcc0                                 dq         0x0                 ; protocols
00000001002afcc8                                 dq         0x1002afd00         ; instance methods
00000001002afcd0                                 dq         0x0                 ; class methods
00000001002afcd8                                 dq         0x0                 ; optional instanceMethods
00000001002afce0                                 dq         0x0                 ; optional class methods
00000001002afce8                                 dq         0x0                 ; instance properties
00000001002afcf0                                 dd         0x00000050          ; size
00000001002afcf4                                 dd         0x00000001          ; flags
00000001002afcf8                                 db  0x20 ; ' '
00000001002afcf9                                 db  0xfd ; '.'
00000001002afcfa                                 db  0x2a ; '*'
00000001002afcfb                                 db  0x00 ; '.'
00000001002afcfc                                 db  0x01 ; '.'
00000001002afcfd                                 db  0x00 ; '.'
00000001002afcfe                                 db  0x00 ; '.'
00000001002afcff                                 db  0x00 ; '.'
00000001002afd00                                 db  0x18 ; '.'                 ; XREF=0x1002afcc8
00000001002afd01                                 db  0x00 ; '.'
00000001002afd02                                 db  0x00 ; '.'
00000001002afd03                                 db  0x00 ; '.'
00000001002afd04                                 db  0x01 ; '.'
00000001002afd05                                 db  0x00 ; '.'
00000001002afd06                                 db  0x00 ; '.'
00000001002afd07                                 db  0x00 ; '.'
00000001002afd08                                 db  0x0a ; '.'
00000001002afd09                                 db  0xf2 ; '.'
00000001002afd0a                                 db  0x26 ; '&'
00000001002afd0b                                 db  0x00 ; '.'
00000001002afd0c                                 db  0x01 ; '.'
00000001002afd0d                                 db  0x00 ; '.'
00000001002afd0e                                 db  0x00 ; '.'
00000001002afd0f                                 db  0x00 ; '.'
00000001002afd10                                 db  0xe0 ; '.'
00000001002afd11                                 db  0x82 ; '.'
00000001002afd12                                 db  0x27 ; '''
00000001002afd13                                 db  0x00 ; '.'
00000001002afd14                                 db  0x01 ; '.'
00000001002afd15                                 db  0x00 ; '.'
00000001002afd16                                 db  0x00 ; '.'
00000001002afd17                                 db  0x00 ; '.'
00000001002afd18                                 db  0x00 ; '.'
00000001002afd19                                 db  0x00 ; '.'
00000001002afd1a                                 db  0x00 ; '.'
00000001002afd1b                                 db  0x00 ; '.'
00000001002afd1c                                 db  0x00 ; '.'
00000001002afd1d                                 db  0x00 ; '.'
00000001002afd1e                                 db  0x00 ; '.'
00000001002afd1f                                 db  0x00 ; '.'
00000001002afd20                                 db  0xe0 ; '.'
00000001002afd21                                 db  0x82 ; '.'
00000001002afd22                                 db  0x27 ; '''
00000001002afd23                                 db  0x00 ; '.'
00000001002afd24                                 db  0x01 ; '.'
00000001002afd25                                 db  0x00 ; '.'
00000001002afd26                                 db  0x00 ; '.'
00000001002afd27                                 db  0x00 ; '.'
                                       ; 
                                       ; Section __objc_selrefs
                                       ; 
                                       ; Range 0x1002afd28 - 0x1002b0360 (1592 bytes)
                                       ; File offset 2817320 (1592 bytes)
                                       ; Flags : 0x10000005
                                       ; 
00000001002afd28                                 dq         0x10026daa6         ; @selector(hash), "hash", XREF=0x1000008e8, -[NSObject hashValue]+4, __TFE10ObjectiveCCSo8NSObjectg9hashValueSi+4, __TFE10FoundationSSg4hashSi+15, _swift_stdlib_NSStringNFDHashValue+27, _swift_stdlib_NSStringASCIIHashValue+10
00000001002afd30                                 dq         0x10026daab         ; @selector(isEqual:), "isEqual:", XREF=__TTWCSo8NSObjects9Equatable10ObjectiveCZFS0_oi2eefTxx_Sb+16, __TZF10ObjectiveCoi2eeFTCSo8NSObjectS0__Sb+16, _swift_stdlib_NSObject_isEqual+21
00000001002afd38                                 dq         0x10026dab4         ; @selector(hashValue), "hashValue", XREF=__TTWCSo8NSObjects8Hashable10ObjectiveCFS0_g9hashValueSi+7
00000001002afd40                                 dq         0x10026dabe         ; @selector(description), "description", XREF=__TTWC
; assembly code goes by
```

But when we declare just `protocol`, here's what you end-up with:

```llvm
0000000100276b90                                 db         "_TtP9Protocols8Protocol_", 0
                                       ; 
                                       ; Section __objc_methname
                                       ; 
                                       ; Range 0x100276ba9 - 0x10027830d (5988 bytes)
                                       ; File offset 2583465 (5988 bytes)
                                       ; Flags : 0x00000002
                                       ; 
0000000100276ba9                                 db         "hash", 0           ; XREF=0x100000210, 0x1002afcf0
0000000100276bae                                 db         "isEqual:", 0       ; XREF=0x1002afcf8
0000000100276bb7                                 db         "hashValue", 0      ; XREF=0x1002afd00
0000000100276bc1                                 db         "description", 0    ; XREF=0x1002afd08
; assembly code goes by
```

Much more assembly, right?

So, let's think this thoroughly, shall we?
`optional` means that a function may or may not exist.
In Objective-C, before passing a message, we have to check for `respondsToSelector`, otherwise it will crash at runtime.
In Swift, we just call the function, followed by a `?`, all safe, no crashes.

But I think that there's a more Swifty way of doing that, by using protocol extensions, take a look:

```swift
protocol Protocol: class {
    func requiredMethodOne()
    func requiredMethodTwo()
}

extension Protocol {
    func optionalMethodOne() {}
    func optionalMethodTwo() {}
}
```

Now, if someone calls `optionalMethodOne()`, nothing happens, due to it's empty implementation. We also mitigate the risk of someone, accidentally, forcing unwrap an optional functional. Not to mention the fact that, now, it's not constraint to a specific type!

Protocol extende all the things!

