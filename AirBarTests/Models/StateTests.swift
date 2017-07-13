//
//  StateTests.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 7/11/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

import XCTest
@testable import AirBar

class StateTests: XCTestCase {
  private let testConfiguration = Configuration(compactStateHeight: 100, normalStateHeight: 200, expandedStateHeight: 300)
  
  func testStateRange() {
    let compactState = State(offset: -100, isExpandedStateAvailable: false, configuration: testConfiguration)
    XCTAssertEqual(compactState.stateRange(), .compactNormal)

    let normalState = State(offset: -200, isExpandedStateAvailable: false, configuration: testConfiguration)
    XCTAssertEqual(normalState.stateRange(), .normalExpanded)

    let expandedState = State(offset: -300, isExpandedStateAvailable: false, configuration: testConfiguration)
    XCTAssertEqual(expandedState.stateRange(), .normalExpanded)
  }

  func testSetOffset() {
    let state = State(offset: -100, isExpandedStateAvailable: false, configuration: testConfiguration)
    let newState = state.set(offset: -250)

    XCTAssertEqual(newState.offset, -250)
  }

  func testAddOffset() {
    let state = State(offset: -100, isExpandedStateAvailable: false, configuration: testConfiguration)
    let newState = state.add(offset: 50)

    XCTAssertEqual(newState.offset, -50)
  }

  func testHeight() {
    let state = State(offset: -50, isExpandedStateAvailable: false, configuration: testConfiguration)
    XCTAssertEqual(state.height(), 50)
  }

  func testTransitionProgress() {
    let normalState = State(offset: -200, isExpandedStateAvailable: false, configuration: testConfiguration)
    XCTAssertEqual(normalState.transitionProgress(), 1)

    let semiExpandedState = State(offset: -240, isExpandedStateAvailable: false, configuration: testConfiguration)
    XCTAssertEqual(semiExpandedState.transitionProgress(), 1.4)

    let compactState = State(offset: -100, isExpandedStateAvailable: false, configuration: testConfiguration)
    XCTAssertEqual(compactState.transitionProgress(), 0)

    let semiNormalState = State(offset: -170, isExpandedStateAvailable: false, configuration: testConfiguration)
    XCTAssertEqual(semiNormalState.transitionProgress(), 0.7)

    let expandedState = State(offset: -300, isExpandedStateAvailable: false, configuration: testConfiguration)
    XCTAssertEqual(expandedState.transitionProgress(), 2)
  }
}
