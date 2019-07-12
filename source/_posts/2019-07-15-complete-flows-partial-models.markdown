---
layout: post
author: rafa
title: "Complete flows, partial models"
date: 2019-07-15 19:55:56 +0200
comments: true
categories: 
---

Most apps these days have a sequence of screens that gather information from the user, like a registration flow, a form of some kind. The data from each step is typically combined into a single data structure.
For example, let's say we want the name, age, and the password to authenticate the user.
<!--more-->
One way to model it is by using the following data structure:

```swift
struct FormData {
    let name: String
    let age: Int
    let password: String
}
```

One issue we are going to come about is that our model is strict, it needs all the values at once, whereas users will supply each value at a time. First they will type in their name, then their age, and so on.
Wrapping up the fields in `Optional`, may loosen its strictness.

```swift
struct FormData {
    let name: String?
    let age: Int?
    let password: String?
}
```

Our flow code might look like:

```swift
func firstStepFinished(with name: String) -> FormData {
    return FormData(name: name, age: nil, password: nil)
}

func secondStepFinished(with age: Int, partialFormData: FormData) -> FormData {
    return FormData(name: partialFormData.name, age: age, password: nil)
}

func thirdStepFinished(with password: String, partialFormData: FormData) {
    let formData = FormData(name: partialFormData.name, age: partialFormData.age, password: password)
    
    api.performLogin(with: formData)
}
```

However, now we need to `guard` against any `nil` values if we want to use them (for example, to make a network request).

```swift
guard let name = formData.name,
      let age = formData.age,
      let password = formData.password {
    return // what should we do here???
}

// use data
```

From a domain perspective, that `return` doesn't make any sense.

One could argue that it's "safe" to force unwrap in this case, or that there is [already a nice approach to this problem](https://www.swiftbysundell.com/posts/handling-non-optional-optionals-in-swift).

One may say, _"we can raise an error to the user"_ or _"we could track it and check if users are getting stuck somehow"_. But, at the end of the day, this is not a good solution because you know that when the flow ends, you have all the values.

Our model is "lying" to us. That's not loosen, it's just flawed.

There are several approaches to make it better, like "one model per step":

```swift
struct FirstStep {
    let name: String
}

struct SecondStep {
    let name: String
    let age: Int
    
    init(firstStep: FirstStep, age: Int) {
        self.name = firstStep.name
        self.age = age
    }
}

struct ThirdStep {
    let name: String
    let age: Int
    let password: String
    
    init(secondStep: SecondStep, password: String) {
        self.name = secondStep.name
        self.age = secondStep.age
        self.password = password
    }
}
```

That's better! But there is also another way of doing things that doesn't involve duplication nor partial data structs.

Instead of breaking down our data structure, why not to break down functions?

Our `FormData` initializer, when interpreted as a function, has this shape:

```swift
(String, Int, String) -> FormData
```

But we can break it down into plain old lambdas[^1], and by applying it to the initializer for our data structure:

```swift
(String) -> (Int) -> (String) -> FormData
```

This technique is called [currying](https://www.pointfree.co/episodes/ep5-higher-order-functions#t42). What it does is, it allow us to translate the evaluation of a function that takes multiple arguments into evaluating a sequence of functions, each with a single argument.

```swift
func curry<A, B, C, D>(
    _ f: @escaping (A, B, C) -> D
) -> (A) -> (B) -> (C) -> D {
    return { a in { b in { c in return f(a, b, c) } } }
}
```

The function above goes from a function that takes multiple arguments `(A, B, C)` and produces a `D`, to single functions, that take one argument each: `(A) -> (B) -> (C)` and produces a `D`, making it possible to partially apply each argument, one at the time, until it can evaluate and return the output value.

Using it in our flow, may look like the following:

```swift
typealias Name = String
typealias Age = Int
typealias Password = String

typealias FromFirstStep = (Age) -> (Password) -> FormData
typealias FromSecondStep = (Password) -> FormData

func firstStepFinished(with name: String) -> FromFirstStep {
    let curried = curry(FormData.init) // (Name) -> (Age) -> (Password) -> FormData
    return curried(name) // (Age) -> (Password) -> FormData
}

func secondStepFinished(with age: Int, partialData: FromFirstStep) -> FromSecondStep {
    return partialData(age) // (Password) -> FormData
}

func thirdStepFinished(with password: String, partialData: FromSecondStep) {
    let formData = partialData(password)
    
    api.performLogin(with: formData)
}
```

I've added a few `type aliases` just to make it more readable.
Cleaning up them further, we'll have:

```swift
typealias FromThirdStep = FormData // just to be explicit
typealias FromSecondStep = (Password) -> FromThirdStep
typealias FromFirstStep = (Age) -> FromSecondStep
```

If you ask me, this is much better because we didn't have to write anything else, other than the `curry`[^2] function itself, which can be used in other places.

And that's it! Functions have saved the day :)

P.S: I want to thank [Sean Olszewski](https://twitter.com/__chefski__), [Gordon Fontenot](https://twitter.com/gfontenot), [Peter Tomaselli](https://github.com/peter-tomaselli), [Henrique Morbin](https://twitter.com/morbin_), [Marcelo Gobetti](https://twitter.com/mwgobetti) and [João Rutkoski](https://github.com/joaortk) for their awesome review.

[^1]: `functions take one argument and return one result.` From the book: [`Haskell Programming from First Principles`](http://haskellbook.com/)

[^2]: Or just use the [Curry.framework](https://github.com/thoughtbot/Curry)