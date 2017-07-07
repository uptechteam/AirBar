//
//  IgnoreBottomDeltaYTransformer.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 7/7/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

internal let ignoreBottomDeltaYTransformer: ContentOffsetDeltaYTransformer = { params -> CGFloat in
  var deltaY = params.contentOffsetDeltaY

  let end = params.scrollable.contentSize.height - params.scrollable.bounds.height + params.scrollable.contentInset.bottom

  if params.contentOffset.y >= end && params.contentOffsetDeltaY < 0 {
    deltaY = max(0, deltaY - params.contentOffset.y + end)
  }

  return deltaY
}
