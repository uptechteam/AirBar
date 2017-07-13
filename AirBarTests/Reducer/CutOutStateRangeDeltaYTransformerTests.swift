//
//  CutOutStateRangeDeltaYTransformerTests.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 7/7/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

import XCTest
@testable import AirBar

class CutOutStateRangeDeltaYTransformerTests: XCTestCase {
  func testTransformerOnExpandWhenExpandedStateIsAvailable() {
    let scrollable = TestScrollable()
    let configuration = Configuration(
      compactStateHeight: 100,
      normalStateHeight: 200,
      expandedStateHeight: 300
    )
    let previousContentOffset = CGPoint(x: 0, y: -280)
    let contentOffset = CGPoint(x: 0, y: -330)
    let state = State(offset: -280, isExpandedStateAvailable: true, configuration: configuration)

    let params = ContentOffsetDeltaYTransformerParameters(
      scrollable: scrollable,
      configuration: configuration,
      previousContentOffset: previousContentOffset,
      contentOffset: contentOffset,
      state: state,
      contentOffsetDeltaY: contentOffset.y - previousContentOffset.y
    )

    let receivedDeltaY = cutOutStateRangeDeltaYTransformer(params)
    XCTAssertEqual(receivedDeltaY, -20)
  }

  func testTransformerOnExpandWhenExpandedStateIsNotAvailable() {
    let scrollable = TestScrollable()
    let configuration = Configuration(
      compactStateHeight: 100,
      normalStateHeight: 200,
      expandedStateHeight: 300
    )
    let previousContentOffset = CGPoint(x: 0, y: -180)
    let contentOffset = CGPoint(x: 0, y: -230)
    let state = State(offset: -180, isExpandedStateAvailable: false, configuration: configuration)

    let params = ContentOffsetDeltaYTransformerParameters(
      scrollable: scrollable,
      configuration: configuration,
      previousContentOffset: previousContentOffset,
      contentOffset: contentOffset,
      state: state,
      contentOffsetDeltaY: contentOffset.y - previousContentOffset.y
    )

    let receivedDeltaY = cutOutStateRangeDeltaYTransformer(params)
    XCTAssertEqual(receivedDeltaY, -20)
  }

  func testTransformerOnConcat() {
    let scrollable = TestScrollable()
    let configuration = Configuration(
      compactStateHeight: 100,
      normalStateHeight: 200,
      expandedStateHeight: 300
    )
    let previousContentOffset = CGPoint(x: 0, y: 200)
    let contentOffset = CGPoint(x: 0, y: 250)
    let state = State(offset: -130, isExpandedStateAvailable: true, configuration: configuration)

    let params = ContentOffsetDeltaYTransformerParameters(
      scrollable: scrollable,
      configuration: configuration,
      previousContentOffset: previousContentOffset,
      contentOffset: contentOffset,
      state: state,
      contentOffsetDeltaY: contentOffset.y - previousContentOffset.y
    )
    
    let receivedDeltaY = cutOutStateRangeDeltaYTransformer(params)
    XCTAssertEqual(receivedDeltaY, 30)
  }
}
