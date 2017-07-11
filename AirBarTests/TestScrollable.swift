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
  var contentOffset = CGPoint() {
    didSet {
      contentOffsetObservable.observer?(contentOffset)
    }
  }
  var contentInset = UIEdgeInsets()
  var scrollIndicatorInsets = UIEdgeInsets()
  var contentSize = CGSize() {
    didSet {
      contentSizeObservable.observer?(contentSize)
    }
  }
  var frame = CGRect()

  let contentSizeObservable = Observable<CGSize>()
  let contentOffsetObservable = Observable<CGPoint>()
  let panGestureStateObservable = Observable<UIGestureRecognizerState>()

  var _updateContentOffsetReceivedArgs: (CGPoint, Bool)?
  func updateContentOffset(_ contentOffset: CGPoint, animated: Bool) {
    _updateContentOffsetReceivedArgs = (contentOffset, animated)
  }
}
