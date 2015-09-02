---
layout: post
title: "Autolayout and NSLocalizedString"
author: rafa
date: 2015-09-02 20:00:52 +0200
comments: false
categories:
---

A localized application is the one that has all of its texts, translated into the users device current language. And this, for us developers, means one thing, and one thing only. Nightmare.

Every time a new translation comes, it's necessary to run the application and check for broken layouts. Take this quite simple UI.

{% img center /images/autolayout-and-nslocalizedstrings/01.png 375 %}

Simple, huh?

All right, here's what you have to do to get covered with future translations, and avoid autolayout nightmares.

Add `-NSDoubleLocalizedStrings YES` to `Arguments Passed On Launch` to the `Run` section at your `Project Schemes`.

{% img center /images/autolayout-and-nslocalizedstrings/02.png %}

This argument will duplicate all strings loaded using `NSLocalizedString`.

{% img center /images/autolayout-and-nslocalizedstrings/03.png 375 %}

What's better then that? What about finding out unlocalized strings?

So, `-NSShowNonLocalizedStrings YES` comes to rescue!

Great! Now you go and get yourself a cup of coffee while the translation team does their job :)