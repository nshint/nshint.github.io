---
layout: post
author: rafa
title: "Wrapping API's using the Builder Pattern"
date: 2016-05-02 22:36:49 +0200
comments: false
categories: 
---

The way I was introduced to the [Design Patterns](http://www.amazon.com/Design-Patterns-Elements-Reusable-Object-Oriented/dp/0201633612) lead me to think that those clever and neat solutions were meant to be used just in big softwares solutions. I never considered using them into the small pieces of software. What do I mean by that? Please, read on.

The Builder Pattern if defined as follows:

> Separate the construction of a complex object from its representation so that the same construction process can create different representations.

<!--more-->
Now, consider for a while the creation of an `UIAlertView` in iOS.

```swift
let alert = UIAlertView(title: "Question", message: "Do you like apples?", delegate: self, cancelButtonTitle: "I hate it!", otherButtonTitles: "Yes, I do!", "More of less")
```

This is a long method call, right? But really, that's not the problem. The problem here is that our class has to conform to `UIAlertViewDelegate` in order to receive the alert result. Wouldn't be nicer to have that logic encapsulated? Well, go back and read the definition for the builder pattern, it fits like a glove, am I right?

An idea on how to wrap the builder pattern around the `UIAlertView` class is as above:

```swift
class AlertBuilder: NSObject, UIAlertViewDelegate {

    typealias AlertBuilderCompletion = Int -> Void

    private var alertTitle: String = ""
    private var alertMessage: String = ""
    private var alertStyle: UIAlertViewStyle = .Default
    private var alertButtonTitles: [String] = []
    private var alertCompletion: AlertBuilderCompletion? = nil

    func title(title: String) -> AlertBuilder {
        alertTitle = title
        return self
    }

    func message(message: String) -> AlertBuilder {
        alertMessage = message
        return self
    }

    func style(style: UIAlertViewStyle) -> AlertBuilder {
        alertStyle = style
        return self
    }

    func buttonTitles(titles: String...) -> AlertBuilder {
        alertButtonTitles = alertButtonTitles + titles
        return self
    }

    func show(completion: AlertBuilderCompletion? = nil) {
        let alertView = UIAlertView()
        alertView.delegate = self
        alertView.title = alertTitle
        alertView.message = alertMessage
        alertView.alertViewStyle = alertStyle

        alertButtonTitles.forEach { title in
            alertView.addButtonWithTitle(title)
        }

        alertCompletion = completion
        alertView.show()
    }

    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        alertCompletion?(buttonIndex)
    }
}
```

Now, all that is necessary to use create an alert is:

```
    alert.title("Question")
    .message("Do you like apples?")
    .buttonTitles("Yes, I do!","More of less", "I hate it!")
    .show { index in
        print(index)
    }
```

In the past, I would have used the first approach and lived with that. Of course, showing alerts to the user is a very tiny part of a real work application. But that's preciselly where I was wrong. This kind of applicability of the builder (among all other design patterns) is what makes software components reusable.
And there are some other places where you could apply the same principle, for example `NSAttributedString` or `UIActionSheet`.

I hope you find that useful. Builder to the rescue!

P.S: Yes, yes I know that Apple has released `UIAlertController` and deprecated both `UIAlertView` and `UIActionSheet`. However, the idea is pretty much the same, alothough what Apple did is Factory instead of a Builder.