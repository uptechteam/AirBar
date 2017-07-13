//
//  IgnoreTopDeltaYTransformerTests.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 7/7/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

import XCTest
@testable import AirBar

class IgnoreTopDeltaYTransformerTests: XCTestCase {
  func testTransformer() {
    let scrollable = TestScrollable()
    scrollable.contentInset = UIEdgeInsets(top: 200, left: 0, bottom: 0, right: 0)
    let configuration = Configuration(
      compactStateHeight: 100,
      normalStateHeight: 200,
      expandedStateHeight: 300
    )
    let previousContentOffset = CGPoint(x: 0, y: -240)
    let contentOffset = CGPoint(x: 0, y: -180)
    let state = State(offset: -200, isExpandedStateAvailable: true, configuration: configuration)

    let params = ContentOffsetDeltaYTransformerParameters(
      scrollable: scrollable,
      configuration: configuration,
      previousContentOffset: previousContentOffset,
      contentOffset: contentOffset,
      state: state,
      contentOffsetDeltaY: contentOffset.y - previousContentOffset.y
    )

    let receivedDeltaY = ignoreTopDeltaYTransformer(params)
    XCTAssertEqual(receivedDeltaY, 20)
  }
}
