---
layout: post
author: wojtek
title: "Storyboard Localization"
date: 2015-06-25 08:00:00 +0200
comments: false
categories: 
---

Internationalizing the users interface in Xcode is [really easy](https://developer.apple.com/library/ios/documentation/MacOSX/Conceptual/BPInternational/InternationalizingYourUserInterface/InternationalizingYourUserInterface.html). Xcode separates all the texts from your views in a dictionary. However, we can make it better, using `extensions` and `@IBDesignables`. How handy would it be, if setting localized strings were as easy as the following?<br/><br/>
{% img center /images/storyboard-localization/1.png %}
<br/>

Easier than that, are the `extensions` to unleash this fancy feature.

```
extension UITextField {

    @IBInspectable var localizedPlaceholder: String {
        get { return "" }
        set {
            self.placeholder = NSLocalizedString(newValue, comment: "")
        }
    }

    @IBInspectable var localizedText: String {
        get { return "" }
        set {
            self.text = NSLocalizedString(newValue, comment: "")
        }
    }
}

extension UITextView {

    @IBInspectable var localizedText: String {
        get { return "" }
        set {
            self.text = NSLocalizedString(newValue, comment: "")
        }
    }
}

extension UIBarItem {

    @IBInspectable var localizedTitle: String {
        get { return "" }
        set {
            self.title = NSLocalizedString(newValue, comment: "")
        }
    }
}

extension UILabel {

    @IBInspectable var localizedText: String {
        get { return "" }
        set {
            self.text = NSLocalizedString(newValue, comment: "")
        }
    }
}

extension UINavigationItem {

    @IBInspectable var localizedTitle: String {
        get { return "" }
        set {
            self.title = NSLocalizedString(newValue, comment: "")
        }
    }
}

extension UIButton {

    @IBInspectable var localizedTitle: String {
        get { return "" }
        set {
            self.setTitle(NSLocalizedString(newValue, comment: ""), forState: UIControlState.Normal)
        }
    }
}

extension UISearchBar {

    @IBInspectable var localizedPrompt: String {
        get { return "" }
        set {
            self.prompt = NSLocalizedString(newValue, comment: "")
        }
    }

    @IBInspectable var localizedPlaceholder: String {
        get { return "" }
        set {
            self.placeholder = NSLocalizedString(newValue, comment: "")
        }
    }
}

extension UISegmentedControl {

    @IBInspectable var localized: Bool {
        get { return true }
        set {
            for index in 0..<numberOfSegments {
                var title = NSLocalizedString(titleForSegmentAtIndex(index)!, comment: "")
                setTitle(title, forSegmentAtIndex: index)
            }
        }
    }
}
```

`UISegmentedControl` may have multiple segments. In this case, set the `localized` to `true` and put the localized key into the storyboard. The extension will lookup into it and return the right value for every segment.

{% img center /images/storyboard-localization/2.png %}

Way better, don't you think? Now you have a shortcut for setting localized strings.
