//
//  CGFloatTests.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 7/11/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

import XCTest
@testable import AirBar

class CGFloatTests: XCTestCase {
  func testIsNear() {
    let testFloat: CGFloat = 0

    XCTAssertTrue(testFloat.isNear(to: 0.1, delta: 0.2))
    XCTAssertTrue(testFloat.isNear(to: 0.2, delta: 0.2))
    XCTAssertFalse(testFloat.isNear(to: 0.3, delta: 0.2))
    XCTAssertFalse(testFloat.isNear(to: 0.4, delta: 0.2))
  }

  func testMap() {
    XCTAssertEqual((0 as CGFloat).map(from: (0, 1), to: (1, 2)), 1)
    XCTAssertEqual((1 as CGFloat).map(from: (0, 1), to: (1, 2)), 2)
    XCTAssertEqual((2 as CGFloat).map(from: (0, 4), to: (1, 2)), 1.5)
    XCTAssertEqual((0 as CGFloat).map(from: (2, 4), to: (1, 2)), 1)
    XCTAssertEqual((10 as CGFloat).map(from: (2, 4), to: (1, 2)), 2)
  }

  func testBounded() {
    XCTAssertEqual((0 as CGFloat).bounded(by: (1, 2)), 1)
    XCTAssertEqual((1 as CGFloat).bounded(by: (-10, -8)), -8)
    XCTAssertEqual((1 as CGFloat).bounded(by: (0, 2)), 1)
  }
}
