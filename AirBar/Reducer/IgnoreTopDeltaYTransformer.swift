//
//  ignoreTopDeltaYTransformer.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 7/7/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

internal let ignoreTopDeltaYTransformer: ContentOffsetDeltaYTransformer = { params -> CGFloat in
  var deltaY = params.contentOffsetDeltaY

  let start = params.scrollable.contentInset.top

  if
    params.previousContentOffset.y < -start ||
      params.contentOffset.y < -start
  {
    deltaY += min(0, params.previousContentOffset.y + start)
  }

  return deltaY
}
