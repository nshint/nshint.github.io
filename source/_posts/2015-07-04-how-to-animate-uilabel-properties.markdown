---
layout: post
title: "How to animate UILabel properties"
date: 2015-07-04 15:53:09 +0200
comments: false
author: marcin
categories: 
---

`UILabel` properties cannot be easy animated due to some various reasons, so code like this will have no effect on it:

```objC
self.someLabel.textColor = [UIColor blueColor];

[UIView animateWithDuration:0.3 
				    animation:^{
	
				  		self.someLabel.textColor = [UIColor redColor];
				  	}];
```

But there is a simple solution. Instead of animating property we will perform transition on object itself.

Using `transitionWithView` should solve our problem:

```objC
self.someLabel.textColor = [UIColor blueColor];

[UIView transitionWithView:self.someLabel 
				    duration:0.3 
				     options:UIViewAnimationOptionTransitionCrossDissolve 
				  animations:^{

    					self.someLabel.textColor = [UIColor redColor];

				  } completion:nil];
```

This creates nice fade in/out animation which is exactly what we want.