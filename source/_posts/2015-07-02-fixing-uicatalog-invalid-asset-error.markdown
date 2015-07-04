---
layout: post
title: "Fixing UICatalog invalid asset error"
date: 2015-07-02 17:29:00 +0200
comments: false
author: marcin
categories: 
---

```
CUICatalog: Invalid asset name supplied: (null), or invalid scale factor: 2.000000
```
This error may happen when you try to load `UIImage` and your asset string is `nil`. For now this will not crash your app but may case some future problems. This may also lead to some UI inconsistency. To track down issue like this we need to set symbolic breakpoint:

{% img center /images/uicatalog_invalid_asset/null_asset.png %}  

Add `$arg3 == nil` condition (on Simulator) or `$r0 == nil` condition on iPhone device. This will stop executing your app exactly in the line where you try to load broken image.
