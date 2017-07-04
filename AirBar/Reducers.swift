//
//  Reducers.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 6/23/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

internal struct StateReducerParameters {
  let scrollable: Scrollable
  let configuration: Configuration
  let previousContentOffset: CGPoint
  let contentOffset: CGPoint
  let isExpandedStateAvailable: Bool
  let state: State
}

internal typealias StateReducer = (StateReducerParameters) -> State

internal func createDefaultStateReducer(middlewares: [ContentOffsetDeltaYMiddleware]) -> StateReducer {
  return { (params: StateReducerParameters) -> State in
    var deltaY = params.contentOffset.y - params.previousContentOffset.y

    deltaY = middlewares.reduce(deltaY) { (deltaY, middleware) -> CGFloat in
      let params = ContentOffsetDeltaYMiddlewareParameters(
        scrollable: params.scrollable,
        previousContentOffset: params.previousContentOffset,
        contentOffset: params.contentOffset,
        contentOffsetDeltaY: deltaY
      )
      return middleware(params)
    }

    let offsetBounds: (CGFloat, CGFloat)
    if params.contentOffset.y < -params.configuration.normalStateHeight && params.isExpandedStateAvailable {
      offsetBounds = (-params.configuration.expandedStateHeight, -params.configuration.normalStateHeight)
    } else {
      offsetBounds = (-params.configuration.normalStateHeight, -params.configuration.compactStateHeight)
    }

    let newOffset = (params.state.offset + deltaY).bounded(by: offsetBounds)

    return State(offset: newOffset, configuration: params.state.configuration)
  }
}
