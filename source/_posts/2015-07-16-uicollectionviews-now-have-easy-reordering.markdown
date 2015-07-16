---
layout: post
title: "UICollectionViews now have easy reordering"
date: 2015-07-16 01:30:09 +0200
comments: true
author: wojtek
categories:
---

I'm a huge fan of `UICollectionView`. It's way more customizable than his older brother `UITableView`. Nowadays I use collection view even more often than table view. With iOS 9 it supports easy reordering. Before it wasn't possible out of the box, and to do so means painful work. Let's have look at the API. You can find the accompanying Xcode project [on GitHub](https://github.com/nshintio/uicollectionview-reordering).

The easiest way to add easy reordering is to use `UICollectionViewController`. It now has a new property called `installsStandardGestureForInteractiveMovement` which adds standard gestures to reorder cells. When setted to `true`, drag and drop cells after long press gesture on cell is enabled. Additionally, you have to implement two `UICollectionViewDataSource` methods.

``` swift
override func collectionView(collectionView: UICollectionView, 
    canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
}

override func collectionView(collectionView: UICollectionView, 
    moveItemAtIndexPath sourceIndexPath: NSIndexPath, 
    toIndexPath destinationIndexPath: NSIndexPath) {
    // swap your data order
}
```

The first one allows to move an item at specified index and second one is responsible to reorder data source. And that's all! We get collection view cells reordering with a couple of lines!

{% img center /images/uicollectionview-reordering/1.gif %}  


Things go complicated when we want to use a simple `UIViewController` with collection view. We also need to implement `UICollectionViewDataSource` methods mentioned above, but we need to rewrite `installsStandardGestureForInteractiveMovement`. No worries, it's also easily supported. First of all, we need to add long press and pan gesture recognizers to our collecton view. The idea is simple. Pan gesture recognizer should be enabled only after get long press gesture on any cell. We can achieve this behaviour in following way.

``` swift
override func viewDidLoad() {
    super.viewDidLoad()

    panGesture = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
    self.collectionView.addGestureRecognizer(panGesture)
    panGesture.delegate = self

    longPressGesture = UILongPressGestureRecognizer(target: self, action: "handleLongGesture:")
    self.collectionView.addGestureRecognizer(longPressGesture)
    longPressGesture.delegate = self
}

func handleLongGesture(gesture: UILongPressGestureRecognizer) {

    switch(gesture.state) {
    case UIGestureRecognizerState.Began:
        selectedIndexPath = self.collectionView.indexPathForItemAtPoint(gesture.locationInView(self.collectionView))
    case UIGestureRecognizerState.Changed:
        break
    default:
        selectedIndexPath = nil
    }
}
```

``` swift
extension ViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        if gestureRecognizer == longPressGesture {
            return panGesture == otherGestureRecognizer
        }

        if gestureRecognizer == panGesture {
            return longPressGesture == otherGestureRecognizer
        }

        return true
    }

    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {

        guard gestureRecognizer == self.panGesture else {
            return true
        }

        return selectedIndexPath != nil
    }
}
```

We stored selected index path obtained in long press gesture handler and depending on wether it has any value we allow to pan gesture to kick in. Also we allow both long press gesture and pan gesture to recognize their gestures simultaneously. So now, we are missing only one little big thing - handle pan gesture. `UICollectionView` gets additional methods just to handle cell's interactive movement:

* `beginInteractiveMovementForItemAtIndexPath(indexPath: NSIndexPath)` which starts interactive movement for cell at specific index path
* `updateInteractiveMovementTargetPosition(targetPosition: CGPoint)` which updates interactive movement target position during gesture
* `endInteractiveMovement()` which ends interactive movement after you finish pan gesture
* `cancelInteractiveMovement()` which cancels interactive movement

And this makes handling pan gesture obvious.

``` swift
func handlePanGesture(gesture: UIPanGestureRecognizer) {

    switch(gesture.state) {
    case UIGestureRecognizerState.Began:
        collectionView.beginInteractiveMovementForItemAtIndexPath(selectedIndexPath!)
    case UIGestureRecognizerState.Changed:
        collectionView.updateInteractiveMovementTargetPosition(gesture.locationInView(gesture.view!))
    case UIGestureRecognizerState.Ended:
        collectionView.endInteractiveMovement()
    default:
        collectionView.cancelInteractiveMovement()
    }
}
```

{% img center /images/uicollectionview-reordering/2.gif %}  

The behaviour is the same as with standard `UICollectionViewController`. Realy cool, but what makes it even cooler is that we can apply reordering to collection view with our custom collection view layout. Check interactive movement with simple waterfall layout.

{% img center /images/uicollectionview-reordering/3.gif %}  

Uhm, looks cool, but what if we don't want to change cell size during movement? Selected cell size during interactive movement should remain the same. This is possible. `UICollectionViewLayout` also gets additional methods to handle reordering.

``` swift
func invalidationContextForInteractivelyMovingItems(targetIndexPaths: [NSIndexPath], 
    withTargetPosition targetPosition: CGPoint, 
    previousIndexPaths: [NSIndexPath], 
    previousPosition: CGPoint) -> UICollectionViewLayoutInvalidationContext

func invalidationContextForEndingInteractiveMovementOfItemsToFinalIndexPaths(indexPaths: [NSIndexPath], 
    previousIndexPaths: [NSIndexPath], 
    movementCancelled: Bool) -> UICollectionViewLayoutInvalidationContext
```

The former is called during the cells interactive movement with target and previous cell's indexPaths. The next one is similar, but it's called just after interactive movement ends. With this knowledge we can achieve our requirement using one little trick.


``` swift
internal override func invalidationContextForInteractivelyMovingItems(targetIndexPaths: [NSIndexPath],
    withTargetPosition targetPosition: CGPoint, 
    previousIndexPaths: [NSIndexPath], 
    previousPosition: CGPoint) -> UICollectionViewLayoutInvalidationContext {

    var context = super.invalidationContextForInteractivelyMovingItems(targetIndexPaths, 
        withTargetPosition: targetPosition, previousIndexPaths: previousIndexPaths, 
        previousPosition: previousPosition)

    self.delegate?.collectionView!(self.collectionView!, moveItemAtIndexPath: previousIndexPaths[0], 
        toIndexPath: targetIndexPaths[0])

    return context
}
```

Solution is straighforward. Grab previous and target index paths of currently moving cell. Then call `UICollectionViewDataSource` method to move this items around.  

{% img center /images/uicollectionview-reordering/4.gif %}  

Without a doubt, a collection view reordering is a fantastic addition. UIKit engineers made awesome job! :) 