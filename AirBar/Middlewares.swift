//
//  Middlewares.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 6/23/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

struct ContentOffsetDeltaYMiddlewareParameters {
  let scrollable: Scrollable
  let previousContentOffset: CGPoint
  let contentOffset: CGPoint
  let contentOffsetDeltaY: CGFloat
}

typealias ContentOffsetDeltaYMiddleware = (ContentOffsetDeltaYMiddlewareParameters) -> CGFloat

internal let ignoreTopDeltaYMiddleware: ContentOffsetDeltaYMiddleware = { params -> CGFloat in
  var deltaY = params.contentOffsetDeltaY

  let start = -params.scrollable.contentInset.top

  if params.contentOffset.y <= start && params.contentOffsetDeltaY > 0 {
    deltaY = min(0, deltaY - (params.contentOffset.y - start))
  }

  return deltaY
}

internal let ignoreBottomDeltaYMiddleware: ContentOffsetDeltaYMiddleware = { params -> CGFloat in
  var deltaY = params.contentOffsetDeltaY

  let end = params.scrollable.contentSize.height - params.scrollable.bounds.height + params.scrollable.contentInset.bottom

  if params.contentOffset.y >= end {
    deltaY = max(0, deltaY - params.contentOffset.y + end)
  }

  return deltaY
}
