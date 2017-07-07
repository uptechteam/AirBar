//
//  CGFloat+AirBar.swift
//  AirBar
//
//  Created by Evgeny Matviyenko on 2/27/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

internal extension CGFloat {
  internal func isNear(to number: CGFloat, delta: CGFloat) -> Bool {
    return self >= (number - delta) && self <= (number + delta)
  }

  internal func map(from firstBounds: (CGFloat, CGFloat), to secondBounds: (CGFloat, CGFloat)) -> CGFloat {
    guard self > firstBounds.0 else {
      return secondBounds.0
    }

    guard self < firstBounds.1 else {
      return secondBounds.1
    }

    let firstBoundsDelta = firstBounds.1 - firstBounds.0
    let ratio = (self - firstBounds.0) / firstBoundsDelta
    return secondBounds.0 + ratio * (secondBounds.1 - secondBounds.0)
  }

  internal func bounded(by bounds: (CGFloat, CGFloat)) -> CGFloat {
    return Swift.max(bounds.0, Swift.min(bounds.1, self))
  }
}
