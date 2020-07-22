---
layout: post
title: "UICollectionViews now have easy reordering"
date: 2015-07-16 01:30:09 +0200
comments: true
author: wojtek
categories:
---

I'm a huge fan of `UICollectionView`. It's way more customizable than his older brother `UITableView`. Nowadays I use collection view even more often than table view. With iOS 9 it supports easy reordering. Before it wasn't possible out of the box, and to do so means painful work. Let's have look at the API. You can find the accompanying Xcode project [on GitHub](https://github.com/nshint/uicollectionview-reordering).
<!--more-->
The easiest way to add easy reordering is to use `UICollectionViewController`. It now has a new property called `installsStandardGestureForInteractiveMovement` which adds standard gestures to reorder cells. This property is `true` by default, which means that there's only one method we should to override to get things working.

``` swift
override func collectionView(collectionView: UICollectionView, 
    moveItemAtIndexPath sourceIndexPath: NSIndexPath, 
    toIndexPath destinationIndexPath: NSIndexPath) {
    // move your data order
}
```
The collection view infers that items can be moved because `moveItemAtIndexPath` is overrired.

{% img center /images/uicollectionview-reordering/1.gif %}  


Things go complicated when we want to use a simple `UIViewController` with collection view. We also need to implement `UICollectionViewDataSource` methods mentioned above, but we need to rewrite `installsStandardGestureForInteractiveMovement`. No worries, it's also easily supported.`UILongPressGestureRecognizer` is a continuous gesture recognizer and fully supports panning.

``` swift
override func viewDidLoad() {
    super.viewDidLoad()

            longPressGesture = UILongPressGestureRecognizer(target: self, action: "handleLongGesture:")
        self.collectionView.addGestureRecognizer(longPressGesture)
}

    func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        
        switch(gesture.state) {
            
        case UIGestureRecognizerState.Began:
            guard let selectedIndexPath = self.collectionView.indexPathForItemAtPoint(gesture.locationInView(self.collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItemAtIndexPath(selectedIndexPath)
        case UIGestureRecognizerState.Changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.locationInView(gesture.view!))
        case UIGestureRecognizerState.Ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
```

We stored selected index path obtained in long press gesture handler and depending on wether it has any value we allow to pan gesture to kick in. Then, we call some new collection view methods accordingly to the gesture state:

* `beginInteractiveMovementForItemAtIndexPath(indexPath: NSIndexPath)` which starts interactive movement for cell at specific index path
* `updateInteractiveMovementTargetPosition(targetPosition: CGPoint)` which updates interactive movement target position during gesture
* `endInteractiveMovement()` which ends interactive movement after you finish pan gesture
* `cancelInteractiveMovement()` which cancels interactive movement

And this makes handling pan gesture obvious.

{% img center /images/uicollectionview-reordering/2.gif %}  

The behavior is the same as with standard `UICollectionViewController`. Really cool, but what makes it even cooler is that we can apply reordering to collection view with our custom collection view layout. Check interactive movement with simple waterfall layout.

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

Solution is straightforward. Grab previous and target index paths of currently moving cell. Then call `UICollectionViewDataSource` method to move this items around.  

{% img center /images/uicollectionview-reordering/4.gif %}  

Without a doubt, a collection view reordering is a fantastic addition. UIKit engineers made awesome job! :)

P.S: I would like to thanks [Douglas Hill](https://twitter.com/qdoug) for hinting out some improvements in our code. Thanks Douglas, keep up the good work!