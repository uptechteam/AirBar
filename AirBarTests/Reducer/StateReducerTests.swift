//
//  StateReducerTests.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 7/11/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

import XCTest
@testable import AirBar

class StateReducerTests: XCTestCase {
  func testMakeDefaultStateReducer() {
    let scrollable = TestScrollable()
    let configuration = Configuration(
      compactStateHeight: 100,
      normalStateHeight: 200,
      expandedStateHeight: 300
    )
    let previousContentOffset = CGPoint(x: 0, y: 200)
    let contentOffset = CGPoint(x: 0, y: 240)
    let state = State(offset: 100, isExpandedStateAvailable: true, configuration: configuration)

    var testFirstTransformerReceivedParams: ContentOffsetDeltaYTransformerParameters?
    let testFirstTransformer: ContentOffsetDeltaYTransformer = { params in
      testFirstTransformerReceivedParams = params
      return params.contentOffsetDeltaY + 20
    }

    var testSecondTransformerReceivedParams: ContentOffsetDeltaYTransformerParameters?
    let testSecondTransformer: ContentOffsetDeltaYTransformer = { params in
      testSecondTransformerReceivedParams = params
      return params.contentOffsetDeltaY + 30
    }

    var testThirdTransformerReceivedParams: ContentOffsetDeltaYTransformerParameters?
    let testThirdTransformer: ContentOffsetDeltaYTransformer = { params in
      testThirdTransformerReceivedParams = params
      return params.contentOffsetDeltaY + 25
    }

    let params = StateReducerParameters(
      scrollable: scrollable,
      configuration: configuration,
      previousContentOffset: previousContentOffset,
      contentOffset: contentOffset,
      state: state
    )

    let stateReducer = makeDefaultStateReducer(transformers: [testFirstTransformer, testSecondTransformer, testThirdTransformer])
    let receivedState = stateReducer(params)
    let expectedState = State(offset: 215, isExpandedStateAvailable: true, configuration: configuration)
    XCTAssertEqual(receivedState, expectedState)

    XCTAssertEqual(testFirstTransformerReceivedParams?.configuration, configuration)
    XCTAssertEqual(testFirstTransformerReceivedParams?.previousContentOffset, previousContentOffset)
    XCTAssertEqual(testFirstTransformerReceivedParams?.contentOffset, contentOffset)
    XCTAssertEqual(testFirstTransformerReceivedParams?.state, state)
    XCTAssertEqual(testFirstTransformerReceivedParams?.contentOffsetDeltaY, 40)

    XCTAssertEqual(testSecondTransformerReceivedParams?.configuration, configuration)
    XCTAssertEqual(testSecondTransformerReceivedParams?.previousContentOffset, previousContentOffset)
    XCTAssertEqual(testSecondTransformerReceivedParams?.contentOffset, contentOffset)
    XCTAssertEqual(testSecondTransformerReceivedParams?.state, state)
    XCTAssertEqual(testSecondTransformerReceivedParams?.contentOffsetDeltaY, 60)

    XCTAssertEqual(testThirdTransformerReceivedParams?.configuration, configuration)
    XCTAssertEqual(testThirdTransformerReceivedParams?.previousContentOffset, previousContentOffset)
    XCTAssertEqual(testThirdTransformerReceivedParams?.contentOffset, contentOffset)
    XCTAssertEqual(testThirdTransformerReceivedParams?.state, state)
    XCTAssertEqual(testThirdTransformerReceivedParams?.contentOffsetDeltaY, 90)
  }
}
