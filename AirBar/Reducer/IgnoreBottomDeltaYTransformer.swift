//
//  IgnoreBottomDeltaYTransformer.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 7/7/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

internal let ignoreBottomDeltaYTransformer: ContentOffsetDeltaYTransformer = { params -> CGFloat in
  var deltaY = params.contentOffsetDeltaY

  let end = params.scrollable.contentSize.height - params.scrollable.frame.height + params.scrollable.contentInset.bottom

  if params.previousContentOffset.y > end ||
      params.contentOffset.y > end
  {
    deltaY += max(0, params.previousContentOffset.y - end)
  }

  return deltaY
}
