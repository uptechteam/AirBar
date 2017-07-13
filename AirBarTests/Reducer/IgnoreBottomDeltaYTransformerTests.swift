//
//  IgnoreBottomDeltaYTransformerTests.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 7/7/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

import XCTest
@testable import AirBar

class IgnoreBottomDeltaYTransformerTests: XCTestCase {
  func testTransformer() {
    let scrollable = TestScrollable()
    scrollable.contentInset.bottom = 200
    scrollable.contentSize.height = 300
    scrollable.frame = CGRect(x: 0, y: 0, width: 0, height: 300)
    let configuration = Configuration(
      compactStateHeight: 100,
      normalStateHeight: 200,
      expandedStateHeight: 300
    )
    let previousContentOffset = CGPoint(x: 0, y: 230)
    let contentOffset = CGPoint(x: 0, y: 180)
    let state = State(offset: -100, isExpandedStateAvailable: true, configuration: configuration)

    let params = ContentOffsetDeltaYTransformerParameters(
      scrollable: scrollable,
      configuration: configuration,
      previousContentOffset: previousContentOffset,
      contentOffset: contentOffset,
      state: state,
      contentOffsetDeltaY: contentOffset.y - previousContentOffset.y
    )

    let receivedDeltaY = ignoreBottomDeltaYTransformer(params)
    XCTAssertEqual(receivedDeltaY, -20)
  }
}
