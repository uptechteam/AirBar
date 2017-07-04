//
//  Scrollable.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 6/23/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

import UIKit

internal protocol Scrollable: class {
  var contentOffset: CGPoint { get }
  var contentInset: UIEdgeInsets { get }
  var contentSize: CGSize { get }
  var bounds: CGRect { get }
  var frame: CGRect { get }
  var contentSizeObservable: Observable<CGSize> { get }
  var contentOffsetObservable: Observable<CGPoint> { get }
  var panGestureStateObservable: Observable<UIGestureRecognizerState> { get }
  func updateContentOffset(_ contentOffset: CGPoint, animated: Bool)
  func updateTopContentInset(_ topContentInset: CGFloat)
  func updateBottomContentInset(_ bottomContentInset: CGFloat)
}

extension UIScrollView: Scrollable {
  var contentSizeObservable: Observable<CGSize> {
    return KVObservable<CGSize>(keyPath: #keyPath(UIScrollView.contentSize), object: self)
  }
  
  var contentOffsetObservable: Observable<CGPoint> {
    return KVObservable<CGPoint>(keyPath: #keyPath(UIScrollView.contentOffset), object: self)
  }
  
  var panGestureStateObservable: Observable<UIGestureRecognizerState> {
    return GestureStateObservable(gestureRecognizer: panGestureRecognizer)
  }
  
  func updateContentOffset(_ contentOffset: CGPoint, animated: Bool) {
    setContentOffset(self.contentOffset, animated: false)

    let animate = {
      self.contentOffset = contentOffset
    }

    guard animated else {
      animate()
      return
    }

    UIView.animate(withDuration: 0.25, delay: 0, options: [], animations: {
      animate()
    }, completion: nil)
  }
  
  func updateTopContentInset(_ topContentInset: CGFloat) {
    self.contentInset.top = topContentInset
  }

  func updateBottomContentInset(_ bottomContentInset: CGFloat) {
    self.contentInset.bottom = bottomContentInset
  }
}
