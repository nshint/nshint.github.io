---
layout: post
author: matt
title: "Testing Codable"
date: 2019-05-10 19:55:56 +0200
comments: true
categories: 
---

Codable is a great protocol available in Swift. It makes it possible to create a type safe JSON representations of structures used within our application with zero boilerplate.

```swift
struct Person: Codable {
    let name: String
    let email: String
    let age: Int
}
```

Once the structure conforms to `Codable` everything works out of the box. There's a nice way to test those structures and make sure that everything gets the exact JSON format that we aligned with backend.
<!--more-->

Let's create the following protocol in the test bundle:
```swift
protocol JSONTestable {
    init?(_ json: String)
    func json() -> String?
}
```

After that we can immediately provide an extension which conforms to that protocol in the test bundle:
```swift
extension JSONTestable where Self: Codable {
    init?(_ json: String) {
        guard
            let data = json.data(using: .utf8),
            let decoded = try? JSONDecoder().decode(Self.self, from: data)
            else { return nil }
        self = decoded
    }

    func json() -> String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
```

Then there's only one simple step which needs to be done in the test bundle in order to test the structure:
`PersonTests.swift`:
```swift
extension Person: JSONTestable {}
```

That's it! Now we can easily test the result of the serialization and deserialization :)

Example tests:
```swift
final class PersonTests: XCTestCase {
    func testJsonSerialization() {
        let person = Person(name: "John Appleased", email: "john@appleased.com", age: 30)
        XCTAssertEqual(personJson, person.json()) // ✅
    }
    
    func testJsonDeserialization() {
        let person = Person(name: "John Appleased", email: "john@appleased.com", age: 30)
        XCTAssertEqual(person, Person(personJson)) // ✅
    }
}

private let personJson = """
{"name":"John Appleased","email":"john@appleased.com","age":30}
"""

extension Person: JSONTestable, Equatable {}
```

What do you think about this method? Is there anything which could be improved in this implementation? Please let us know :)