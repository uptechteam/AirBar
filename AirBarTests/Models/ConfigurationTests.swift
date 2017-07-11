//
//  ConfigurationTests.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 7/11/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

import XCTest
@testable import AirBar

class ConfigurationTests: XCTestCase {
  func testOffsetBounds() {
    let configuration = Configuration(compactStateHeight: 100, normalStateHeight: 200, expandedStateHeight: 300)

    let compactNormalOffsetBounds = configuration.offsetBounds(for: .compactNormal)
    XCTAssertEqual(compactNormalOffsetBounds.0, -configuration.normalStateHeight)
    XCTAssertEqual(compactNormalOffsetBounds.1, -configuration.compactStateHeight)

    let normalExpandedOffsetBounds = configuration.offsetBounds(for: .normalExpanded)
    XCTAssertEqual(normalExpandedOffsetBounds.0, -configuration.expandedStateHeight)
    XCTAssertEqual(normalExpandedOffsetBounds.1, -configuration.normalStateHeight)
  }
}
