//
//  StateReducer.swift
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
  let state: State
}

internal typealias StateReducer = (StateReducerParameters) -> State

internal struct ContentOffsetDeltaYTransformerParameters {
  let scrollable: Scrollable
  let configuration: Configuration
  let previousContentOffset: CGPoint
  let contentOffset: CGPoint
  let state: State
  let contentOffsetDeltaY: CGFloat
}

internal typealias ContentOffsetDeltaYTransformer = (ContentOffsetDeltaYTransformerParameters) -> CGFloat

internal func makeDefaultStateReducer(transformers: [ContentOffsetDeltaYTransformer]) -> StateReducer {
  return { (params: StateReducerParameters) -> State in
    var deltaY = params.contentOffset.y - params.previousContentOffset.y

    deltaY = transformers.reduce(deltaY) { (deltaY, transformer) -> CGFloat in
      let params = ContentOffsetDeltaYTransformerParameters(
        scrollable: params.scrollable,
        configuration: params.configuration,
        previousContentOffset: params.previousContentOffset,
        contentOffset: params.contentOffset,
        state: params.state,
        contentOffsetDeltaY: deltaY
      )
      return transformer(params)
    }

    return params.state.add(offset: deltaY)
  }
}
