//
//  StateRangeTests.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 7/11/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

import XCTest
@testable import AirBar

class StateRangeTests: XCTestCase {
  func testProgressBounds() {
    let compactNormalProgressBounds = StateRange.compactNormal.progressBounds()
    XCTAssertEqual(compactNormalProgressBounds.0, 0)
    XCTAssertEqual(compactNormalProgressBounds.1, 1)

    let normalExpandedProgressBounds = StateRange.normalExpanded.progressBounds()
    XCTAssertEqual(normalExpandedProgressBounds.0, 1)
    XCTAssertEqual(normalExpandedProgressBounds.1, 2)
  }
}
