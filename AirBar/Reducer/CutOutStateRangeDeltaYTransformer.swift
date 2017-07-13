//
//  CutOutStateRangeDeltaYTransformer.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 7/7/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

internal let cutOutStateRangeDeltaYTransformer: ContentOffsetDeltaYTransformer = { params -> CGFloat in
  var deltaY = params.contentOffsetDeltaY

  if deltaY > 0 {
    deltaY = min(-params.configuration.compactStateHeight, (params.state.offset + deltaY)) - params.state.offset
  } else {
    let maxStateHeight = params.state.isExpandedStateAvailable ? params.configuration.expandedStateHeight : params.configuration.normalStateHeight
    deltaY = max(-maxStateHeight, (params.state.offset + deltaY)) - params.state.offset
  }

  return deltaY
}
