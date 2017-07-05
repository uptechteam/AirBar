//
//  TestScrollable.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 7/5/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

import XCTest
@testable import AirBar

class TestScrollable: Scrollable {
  var contentOffset = CGPoint()
  var contentInset = UIEdgeInsets()
  var scrollIndicatorInsets = UIEdgeInsets()
  var contentSize = CGSize()
  var bounds = CGRect()
  var frame = CGRect()

  var _contentSizeObservable: Observable<CGSize>!
  var contentSizeObservable: Observable<CGSize> { return _contentSizeObservable }

  var _contentOffsetObservable: Observable<CGPoint>!
  var contentOffsetObservable: Observable<CGPoint> { return _contentOffsetObservable }

  var _panGestureStateObservable: Observable<UIGestureRecognizerState>!
  var panGestureStateObservable: Observable<UIGestureRecognizerState> { return _panGestureStateObservable }

  var _updateContentOffsetReceivedArgs: (CGPoint, Bool)?
  func updateContentOffset(_ contentOffset: CGPoint, animated: Bool) {
    _updateContentOffsetReceivedArgs = (contentOffset, animated)
  }
}
