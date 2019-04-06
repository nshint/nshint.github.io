---
layout: post
author: rafa
title: "Testing the camera on the simulator"
date: 2019-04-08 22:36:49 +0200
comments: false
categories: 
---

Testing code often demands faking the "real world". [IoC](https://en.wikipedia.org/wiki/Inversion_of_control) plays a huge role in here where you flip the dependency from a concrete implementation to an interface.

This technique is very useful when you want to abstract away third-party code (think `UserDefaults`), but there are instances where this is not enough. That's the case when working with the camera.

On iOS, to use the camera, one has to use the machinery that comes with  [`AVFoundation`](https://developer.apple.com/documentation/avfoundation/cameras_and_media_capture).

<!--more-->

Although you can use `protocols` to generalize the real objects, at some point, you are going to stumble upon a dilemma: the simulator doesn't have a camera, and you can't instantiate the framework classes making the tests (almost) impossible.

#### What are you talking about?

Let's start with a very simple program that captures QR Code (I'm skipping lots of boilerplate but if you are looking for a more thorough example, [here](https://www.hackingwithswift.com/example-code/media/how-to-scan-a-qr-code) you have a great article).

```swift
enum CameraError: Error {
    case invalidMetadata
}

protocol CameraOutputDelegate: class {
    func qrCode(read code: String)
    func qrCode(failed error: CameraError)
}

final class Camera: NSObject {
    private let session: AVCaptureSession
    private let metadataOutput: AVCaptureMetadataOutput
    private weak var delegate: CameraOutputDelegate?

    public init(
        session: AVCaptureSession = AVCaptureSession(),
        metadataOutput: AVCaptureMetadataOutput = AVCaptureMetadataOutput(),
        delegate: CameraOutputDelegate?
    ) {
        self.session = session
        self.metadataOutput = metadataOutput

        super.init()

        self.metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
    }
}

extension Camera: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let code = object.stringValue, object.type == .qr else {
                delegate?.qrCode(failed: .invalidMetadata)
                return
        }

        delegate?.qrCode(read: code)
    }
}
```

When the detection happens, you can compute from framework-provided values, by implementing the following method from [`AVCaptureMetadataOutputObjectsDelegate`](https://developer.apple.com/documentation/avfoundation/avcapturemetadataoutputobjectsdelegate/1389481-metadataoutput). Say we want to exercise our program in a way that we ensure that the `CameraOutputDelegate` methods are properly called, given what `AVFoundation` provides.

```swift
final class CameraOutputSpy: CameraOutputDelegate {
    var qrCodeReadCalled: Bool?
    var qrCodePassed: String?
    var qrCodeFailedCalled: Bool?
    var qrCodeErrorPassed: CameraError?

    func qrCode(read code: String) {
        qrCodeReadCalled = true
        qrCodePassed = code
    }
    func qrCode(failed error: CameraError) {
        qrCodeFailedCalled = true
        qrCodeErrorPassed = error
    }
}

let delegate = CameraOutputSpy()

let camera = Camera(
    session: AVCaptureSession(),
    metadataOutput: AVCaptureMetadataOutput(),
    delegate: delegate
)

camera.metadataOutput(
    AVCaptureMetadataOutput(),
    didOutput: [AVMetadataMachineReadableCodeObject()], // error: 'init()' is unavailable
    from: AVCaptureConnection() //error: 'init()' is unavailable
)
```

Waat!?

The problem here is that all of these classes are concrete, so we can't abstract them into an interface. Also they are supposed to be created and populated at runtime, hence you can't `init` them.

#### 🍸 `Swizzle` to the rescue

One possible solution for this kind of scenario (since the framework it's all `Objective-C`...for now at least), is to use the [`Objective-C` runtime shenanigans](https://nshipster.com/method-swizzling/) to "fill this gap".

This is only possible because in `Objective-C` the method to call when a message is sent to an object is resolved at runtime.

I'm not going to lay down the nitty-gritty details about how it works, but the main idea (for the sake of this example) is to, at runtime, copy the implementation of `NSObject.init` and exchange it with some new fake `init` we are going to create.

```swift
struct Swizzler {
    private let klass: AnyClass

    init(_ klass: AnyClass) {
        self.klass = klass
    }

    func injectNSObjectInit(into selector: Selector) {
        let original = [
            class_getInstanceMethod(klass, selector)
        ].compactMap { $0 }

        let swizzled = [
            class_getInstanceMethod(klass, #selector(NSObject.init))
        ].compactMap { $0 }

        zip(original, swizzled)
            .forEach {
                method_setImplementation($0.0, method_getImplementation($0.1))
        }
    }
}
```

With that in hand, now we can:

1. Create a `private init` that will hold the implemetation of `NSObject.init`.
2. Create our "designated initializer", capturing the parameters our test needs.
3. Do the swizzle dance.

```swift
final class FakeMachineReadableCodeObject: AVMetadataMachineReadableCodeObject {
    var code: String?
    var dataType: AVMetadataObject.ObjectType = .qr

    override var stringValue: String? {
        return code
    }

    override var type: AVMetadataObject.ObjectType {
        return dataType
    }

    // 1
    @objc private convenience init(fake: String) { fatalError() }

    private class func fake(fake: String, type: AVMetadataObject.ObjectType = .qr) -> FakeMachineReadableCodeObject? {
        let m = FakeMachineReadableCodeObject(fake: fake)
        m.code = fake
        m.dataType = type

        return m
    }

    // 2
    static func createFake(code: String, type: AVMetadataObject.ObjectType) -> FakeMachineReadableCodeObject? {
        // 3
        Swizzler(self).injectNSObjectInit(into: #selector(FakeMachineReadableCodeObject.init(fake:)))
        return fake(fake: code, type: type)
    }
}
```

Now, we can create a fake QR code payload in our tests and check if your implementation of `AVCaptureMetadataOutputObjectsDelegate` does what you expect it to.

```swift
let delegate = CameraOutputSpy()

let camera = Camera(
    session: AVCaptureSession(),
    metadataOutput: AVCaptureMetadataOutput(),
    delegate: delegate
)

camera.metadataOutput(
    QRMetadataOutputFake(), // plain ol' subclass, not really important
    didOutput: [
        FakeMachineReadableCodeObject.createFake(code: "interleaved2of5 value", type: . interleaved2of5)!
        FakeMachineReadableCodeObject.createFake(code: "QR code value", type: .qr)!
    ],
    from: AVCaptureConnection(
        inputPorts: [],
        output: AVCaptureOutput.createFake! // Another swizzle
  )
)

XCTAssertEqual(delegate.qrCodeReadCalled, true)
XCTAssertEqual(delegate.qrCodePassed, "QR code value")
XCTAssertNil(delegate.qrCodeFailedCalled)
XCTAssertNil(delegate.qrCodeErrorPassed)

```

As you can see, you can also check if your [`sut`](https://en.wikipedia.org/wiki/System_under_test) handles just QR code.

You can use this technique along side with other collaborators, like `AVCaptureDevice`, `AVCaptureInput` and `AVCaptureOutput`.