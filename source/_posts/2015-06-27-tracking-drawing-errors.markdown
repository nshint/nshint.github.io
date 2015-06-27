---
layout: post
title: "Tracking down drawing errors"
date: 2015-06-27 11:35:32 +0200
comments: false
author: marcin
categories: 
---
Do you sometimes see this in your code while performing custom drawing using <code>drawRect</code>?

```
<Error>: CGContextSaveGState: invalid context 0x0
<Error>: CGContextSetBlendMode: invalid context 0x0
<Error>: CGContextSetAlpha: invalid context 0x0
<Error>: CGContextTranslateCTM: invalid context 0x0
<Error>: CGContextScaleCTM: invalid context 0x0
<Error>: CGContextDrawImage: invalid context 0x0
<Error>: CGContextRestoreGState: invalid context 0x0
```

And as always is very hard to track, because you cannot exactly say which draw command actually cause this or where does it comes from.
But there is a simple solution to this:

Use this symbolic breakpoint <code>CGPostError</code> in your xcode to stop executing on exact line where drawing error appears.

{% img center /images/track-drawin-errors/screen_cgposterror.png %}  

Now you can see all callstack and all values to find root cause of incorrect drawing.


