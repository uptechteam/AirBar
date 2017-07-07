//
//  StateReducerMiddlewaresTests.swift
//  AirBarTests
//
//  Created by Евгений Матвиенко on 7/5/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

import XCTest
@testable import AirBar

class StateReducerMiddlewaresTests: XCTestCase {
  func testIgnoreTopDeltaYMiddlewareOnExpand() {
    let scrollable = TestScrollable()
    scrollable.contentInset = UIEdgeInsets(top: 300, left: 0, bottom: 0, right: 0)
    let configuration = Configuration(
      compactStateHeight: 100,
      normalStateHeight: 200,
      expandedStateHeight: 300
    )
    let previousContentOffset = CGPoint(x: 0, y: -320)
    let contentOffset = CGPoint(x: 0, y: -270)
    let isExpandedStateAvailable = true
    let state = State(offset: -300, configuration: configuration)

    let params = ContentOffsetDeltaYMiddlewareParameters(
      scrollable: scrollable,
      configuration: configuration,
      previousContentOffset: previousContentOffset,
      contentOffset: contentOffset,
      isExpandedStateAvailable: isExpandedStateAvailable,
      state: state,
      contentOffsetDeltaY: contentOffset.y - previousContentOffset.y
    )

    let receivedDeltaY = ignoreTopDeltaYMiddleware(params)
    XCTAssertEqual(receivedDeltaY, 30)
  }

  func testIgnoreTopDeltaYMiddlewareOnConcat() {
    let scrollable = TestScrollable()
    scrollable.contentInset = UIEdgeInsets(top: 300, left: 0, bottom: 0, right: 0)
    let configuration = Configuration(
      compactStateHeight: 100,
      normalStateHeight: 200,
      expandedStateHeight: 300
    )
    let previousContentOffset = CGPoint(x: 0, y: -270)
    let contentOffset = CGPoint(x: 0, y: -320)
    let isExpandedStateAvailable = true
    let state = State(offset: -300, configuration: configuration)

    let params = ContentOffsetDeltaYMiddlewareParameters(
      scrollable: scrollable,
      configuration: configuration,
      previousContentOffset: previousContentOffset,
      contentOffset: contentOffset,
      isExpandedStateAvailable: isExpandedStateAvailable,
      state: state,
      contentOffsetDeltaY: contentOffset.y - previousContentOffset.y
    )

    let receivedDeltaY = ignoreTopDeltaYMiddleware(params)
    XCTAssertEqual(receivedDeltaY, -20)
  }

  func testCutOutStateRangeDeltaYMiddlewareBlocksExpandedState() {
    let scrollable = TestScrollable()
    let configuration = Configuration(
      compactStateHeight: 100,
      normalStateHeight: 200,
      expandedStateHeight: 300
    )
    let previousContentOffset = CGPoint(x: 0, y: 200)
    let contentOffset = CGPoint(x: 0, y: 100)
    let isExpandedStateAvailable = false
    let state = State(offset: -200, configuration: configuration)

    let params = ContentOffsetDeltaYMiddlewareParameters(
      scrollable: scrollable,
      configuration: configuration,
      previousContentOffset: previousContentOffset,
      contentOffset: contentOffset,
      isExpandedStateAvailable: isExpandedStateAvailable,
      state: state,
      contentOffsetDeltaY: contentOffset.y - previousContentOffset.y
    )

    let receivedDeltaY = cutOutStateRangeDeltaYMiddleware(params)
    XCTAssertEqual(receivedDeltaY, 0)
  }

  func testCutOutStateRangeDeltaYMiddlewareShowsExpandedState() {
    let scrollable = TestScrollable()
    let configuration = Configuration(
      compactStateHeight: 100,
      normalStateHeight: 200,
      expandedStateHeight: 300
    )
    let previousContentOffset = CGPoint(x: 0, y: -180)
    let contentOffset = CGPoint(x: 0, y: -240)
    let isExpandedStateAvailable = true
    let state = State(offset: -200, configuration: configuration)

    let params = ContentOffsetDeltaYMiddlewareParameters(
      scrollable: scrollable,
      configuration: configuration,
      previousContentOffset: previousContentOffset,
      contentOffset: contentOffset,
      isExpandedStateAvailable: isExpandedStateAvailable,
      state: state,
      contentOffsetDeltaY: contentOffset.y - previousContentOffset.y
    )

    let receivedDeltaY = cutOutStateRangeDeltaYMiddleware(params)
    XCTAssertEqual(receivedDeltaY, -40)
  }
}
