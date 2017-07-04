//
//  Reducers.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 6/23/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

internal typealias State = CGFloat

internal struct StateReducerParameters {
  let scrollable: Scrollable
  let configuration: BarConfiguration
  let previousContentOffset: CGPoint
  let contentOffset: CGPoint
  let state: State
}

internal typealias StateReducer = (StateReducerParameters) -> State

internal func createDefaultStateReducer(middlewares: [ContentOffsetDeltaYMiddleware]) -> StateReducer {
  return { (params: StateReducerParameters) -> State in
    var state = params.state

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

    let currentStateRange = stateRange(contentOffset: params.contentOffset, configuration: params.configuration)
    let previousStateRange = stateRange(contentOffset: params.previousContentOffset, configuration: params.configuration)

    let currentHeightDelta = params.configuration.height(for: currentStateRange.1) - params.configuration.height(for: currentStateRange.0)
    let previousHeightDelta = params.configuration.height(for: previousStateRange.1) - params.configuration.height(for: previousStateRange.0)

    let stateDelta: CGFloat
    if currentStateRange.0 == previousStateRange.0 && currentStateRange.1 == previousStateRange.1 {
      stateDelta = AirBar.stateDelta(contentOffset: params.contentOffset, configuration: params.configuration, deltaY: deltaY)
    } else {
      let firstPartDeltaY = max(-params.configuration.normalStateHeight - params.previousContentOffset.y, deltaY)
      let secondPartDeltaY = deltaY - firstPartDeltaY

      let firstPartStateDelta = firstPartDeltaY.map(from: (-previousHeightDelta, previousHeightDelta), to: (-1, 1))
      let secondPartStateDelta = secondPartDeltaY.map(from: (-currentHeightDelta, currentHeightDelta), to: (-1, 1))
      stateDelta = firstPartStateDelta + secondPartStateDelta
    }

    state = state - stateDelta
    state = state.bounded(by: (AirBarState.compact.rawValue, AirBarState.expanded.rawValue))

    return state
  }
}

private func stateDelta(contentOffset: CGPoint, configuration: BarConfiguration, deltaY: CGFloat) -> CGFloat {
  let states = stateRange(contentOffset: contentOffset, configuration: configuration)
  let heightDelta = configuration.height(for: states.1) - configuration.height(for: states.0)
  return deltaY.map(from: (-heightDelta, heightDelta), to: (-1, 1))
}

private func stateRange(contentOffset: CGPoint, configuration: BarConfiguration) -> (AirBarState, AirBarState) {
  if contentOffset.y < -configuration.normalStateHeight {
    return (AirBarState.normal, AirBarState.expanded)
  } else {
    return (AirBarState.compact, AirBarState.normal)
  }
}
