---
layout: post
title: "Using sql as date formatter"
date: 2015-08-04 20:50:51 +0200
comments: false
author: marcin
categories: 
---

This post is a quick update to [Vombat's blog post](http://vombat.tumblr.com/post/60530544401/date-parsing-performance-on-ios-nsdateformatter) about using SQL instead of `NSDateFormatter` when it comes to parsing dates in your project. If you don't read it yet, I will highly recommend to do it now. This time we will use Swift to make same measurements.

TL;DR:

You can use sql database function `strftime` to get UNIX time from e.g.: ISO8061 date string.

Here is the magic function:

```objc
+ (NSArray *)parseDatesUsingStringArray:(NSArray *)stringsArray
{
    sqlite3 *db = NULL;
    sqlite3_open(":memory:", &db);
    
    sqlite3_stmt *statement = NULL;
    sqlite3_prepare_v2(db, "SELECT strftime('%s', ?);", -1, &statement, NULL);
    
    NSMutableArray *datesArray = [NSMutableArray array];
    
    for (NSInteger i = 0; i < stringsArray.count; i++)
    {
        NSString *dateString = stringsArray[i];
        
        sqlite3_bind_text(statement, 1, [dateString UTF8String], -1, SQLITE_STATIC);
        sqlite3_step(statement);
        
        kTimeStamp value = sqlite3_column_int64(statement, 0);
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:value];
        
        [datesArray addObject:date];
        
        sqlite3_clear_bindings(statement);
        sqlite3_reset(statement);
    }
    
    sqlite3_close(db);
    
    return datesArray;
}
```

We will use it to replace standard parsing method like this:

```swift
var datesFromNSDateFormatter:[NSDate] = []

for string in stringsArray {              
	datesFromNSDateFormatter.append(NSDateFormatter.dateFromISOString(string))
}
```

I did some measurements using iPhone 5S with iOS8.2 in release configuration running exactly same amount of data (One Milion strings with ISO8601 date)

And here are the results:

```
Time elapsed for NSDateFromatter parsing: 73.7988719940186 s
Time elapsed for SQLDateFormatter parsing: 8.51147103309631 s
```

So using SQL to format string into date is pretty fast but acutally slower than objC version (But still at least 10time faster than regular method) So what about Swift?. Nothing really changed, overall results show faster computation but I'm using better CPU so `NSDateFormatter` is still very very slow... If you like it, sample source code is available on <a href="https://github.com/noxytrux/DateFormatter">Github</a>


