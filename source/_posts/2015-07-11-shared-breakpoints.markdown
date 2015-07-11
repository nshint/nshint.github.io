---
layout: post
author: rafa
title: "Shared breakpoints"
date: 2015-07-11 14:00:40 -0300
comments: false
categories: 
---
Developing multithreaded application is not something new and it's become more and more popular with multicore processors. One thing it's for sure, debugging multithread applications is tough.

iOS has some gotchas regarding multithread, things that if you don't respect, may cause your application to crash or hang the users interface, for example:

- Animations outside the main thread, may crash the application.<br/>
- Performing network requests on the main thread, will hang the users interface.<br/>

{% img left /images/shared-breakpoints/1.png %}
We can solve those situations using the so called `Symbolic Breakpoints` and [share those breakpoints](https://developer.apple.com/library/ios/recipes/xcode_help-breakpoint_navigator/articles/sharing_a_breakpoint.html) with your team. Thereby, every developer can take advantage of that, and get notified, when they occur.

To help you out, we created a bunch of shared breakpoints and integrate them into your project is very easy:

{% img right /images/shared-breakpoints/2.png %}
- Go to your `.xcodeproj` or `.xcworkspace` file, right click on it, and choose `Show Package Contents`.<br/>
- Open the folder `xcshareddata`, then `xcdebugger` (create them if not exists).<br/>
- Breakpoints are saved into `Breakpoints_v2.xcbkptlist`.<br/>
-  Now you just have to paste the following content into the `<Breakpoints>` node.

(We could also add those using [`LLDB` commands](https://developer.apple.com/library/mac/documentation/IDEs/Conceptual/gdb_to_lldb_transition_guide/document/lldb-terminal-workflow-tutorial.html), but those won't show up on the Breakpoints navigator)

{% img center /images/shared-breakpoints/3.png %}

Our list of useful breakpoints [is available here](https://gist.github.com/rakaramos/d2bc8e75ae68ac830a59)

Now, whenever the breakpoint conditions are satisfied, you'll be notified and will have a chance to quickly fix your code, before it crashes into the users hand!

{% img center /images/shared-breakpoints/4.png %}