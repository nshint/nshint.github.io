---
layout: post
title: "Fixing UICatalog invalid asset error"
date: 2015-07-02 17:29:00 +0200
comments: false
author: marcin
categories: 
---

<code>CUICatalog: Invalid asset name supplied: (null), or invalid scale factor: 2.000000</code> This error may happen when you try to load <code>UIImage</code> and your asset string is <code>nil</code>. For now this will not crash your app but may case some future problems. This may also lead to some UI inconsistency. To track down issue like this we need to set symbolic breakpoint:

{% img center /images/uicatalog_invalid_asset/null_asset.png %}  

Add <code>$arg3 == nil</code> condition (on Simulator) or <code>$r0 == nil</code> condition on iPhone device. This will stop executing your app exactly in the line where you try to load broken image.