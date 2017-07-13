//
//  BarControllerTests.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 7/5/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

import XCTest
@testable import AirBar

class BarControllerTests: XCTestCase {
  private var stateReducer: StateReducer!
  private var configuration: Configuration!
  private var stateObserver: StateObserver!

  private var barController: BarController!

  private var latestReceivedStateReducerParams: StateReducerParameters?
  private var latestState: State?

  override func setUp() {
    stateReducer = { params -> State in
      self.latestReceivedStateReducerParams = params
      let deltaY = params.contentOffset.y - params.previousContentOffset.y
      return params.state.add(offset: deltaY)
    }

    configuration = Configuration(
      compactStateHeight: 100,
      normalStateHeight: 200,
      expandedStateHeight: 300
    )

    stateObserver = { state in
      self.latestState = state
    }

    barController = BarController(
      stateReducer: stateReducer,
      configuration: configuration,
      stateObserver: stateObserver
    )
  }

  func testInitialStateIsNormal() {
    let scrollable = TestScrollable()

    barController.set(scrollable: scrollable)

    XCTAssertEqual(latestState?.offset, -200)
  }

  func testStateReducerCallsOnContentOffsetChange() {
    let scrollable = TestScrollable()

    barController.set(scrollable: scrollable)

    scrollable.contentOffset = CGPoint(x: 0, y: -200)
    XCTAssertEqual(latestState?.height(), 200)

    scrollable.contentOffset = CGPoint(x: 0, y: -180)
    XCTAssertEqual(latestState?.height(), 180)

    scrollable.contentOffset = CGPoint(x: 0, y: -540)
    XCTAssertEqual(latestState?.height(), 540)

    XCTAssertEqual(latestReceivedStateReducerParams?.contentOffset.y, -540)
  }

  func testPanGestureBeganChangesTopContentInset() {
    let scrollable = TestScrollable()

    barController.set(scrollable: scrollable)

    scrollable.contentOffset = CGPoint(x: 0, y: -140)
    scrollable.panGestureStateObservable.observer?(.began)
    XCTAssertEqual(scrollable.contentInset.top, 200)

    scrollable.contentOffset = CGPoint(x: 0, y: -200)
    scrollable.panGestureStateObservable.observer?(.began)
    XCTAssertEqual(scrollable.contentInset.top, 300)
  }

  func testExpandedStateDisablesAfterScrollingBelowNormalState() {
    let scrollable = TestScrollable()

    barController.set(scrollable: scrollable)

    scrollable.contentOffset = CGPoint(x: 0, y: -200)
    scrollable.panGestureStateObservable.observer?(.began)
    scrollable.contentOffset = CGPoint(x: 0, y: -210)
    XCTAssertEqual(latestState?.isExpandedStateAvailable, true)

    scrollable.contentOffset = CGPoint(x: 0, y: -220)
    scrollable.panGestureStateObservable.observer?(.changed)
    scrollable.contentOffset = CGPoint(x: 0, y: -230)
    XCTAssertEqual(latestState?.isExpandedStateAvailable, true)

    scrollable.contentOffset = CGPoint(x: 0, y: -240)
    scrollable.panGestureStateObservable.observer?(.changed)
    scrollable.contentOffset = CGPoint(x: 0, y: -250)
    XCTAssertEqual(latestState?.isExpandedStateAvailable, true)

    scrollable.contentOffset = CGPoint(x: 0, y: -180)
    scrollable.panGestureStateObservable.observer?(.changed)
    scrollable.contentOffset = CGPoint(x: 0, y: -170)
    XCTAssertEqual(latestState?.isExpandedStateAvailable, false)
  }

  func testPanGestureEndUpdatesContentOffsetToNearestState() {
    let scrollable = TestScrollable()

    barController.set(scrollable: scrollable)

    scrollable.contentOffset = CGPoint(x: 0, y: -200)
    scrollable.contentOffset = CGPoint(x: 0, y: -240)
    scrollable.panGestureStateObservable.observer?(.ended)
    XCTAssertEqual(scrollable._updateContentOffsetReceivedArgs?.0.y, -200)

    scrollable.contentOffset = CGPoint(x: 0, y: -260)
    scrollable.panGestureStateObservable.observer?(.ended)
    XCTAssertEqual(scrollable._updateContentOffsetReceivedArgs?.0.y, -300)

    scrollable.contentOffset = CGPoint(x: 0, y: -140)
    scrollable.panGestureStateObservable.observer?(.ended)
    XCTAssertEqual(scrollable._updateContentOffsetReceivedArgs?.0.y, -100)
  }

  func testExpand() {
    let scrollable = TestScrollable()

    barController.set(scrollable: scrollable)

    barController.expand(on: true)
    XCTAssertEqual(scrollable._updateContentOffsetReceivedArgs?.0.y, -300)
    XCTAssertEqual(scrollable.contentInset.top, 300)

    barController.expand(on: false)
    XCTAssertEqual(scrollable._updateContentOffsetReceivedArgs?.0.y, -200)
    XCTAssertEqual(scrollable.contentInset.top, 200)
  }

  func testContentSizeChangesUpdateScrollableContentOffsetToTop() {
    let scrollable = TestScrollable()
    scrollable.frame = CGRect(x: 0, y: 0, width: 0, height: 400)
    scrollable.contentSize = CGSize(width: 0, height: 500)
    barController.set(scrollable: scrollable)

    scrollable.contentOffset = CGPoint(x: 0, y: 100)
    scrollable.contentSize = CGSize(width: 0, height: 200)
    XCTAssertEqual(scrollable._updateContentOffsetReceivedArgs?.0.y, -200)
    scrollable._updateContentOffsetReceivedArgs = nil

    scrollable.contentOffset = CGPoint(x: 0, y: 100)
    scrollable.contentSize = CGSize(width: 0, height: 500)
    XCTAssertNil(scrollable._updateContentOffsetReceivedArgs)
  }

  func testPreconfigureOnExpandedState() {
    let scrollable = TestScrollable()
    barController.set(scrollable: scrollable)

    scrollable.contentOffset = CGPoint(x: 0, y: -200)

    scrollable.panGestureStateObservable.observer?(.began)

    scrollable.contentOffset = CGPoint(x: 0, y: -300)

    let secondScrollable = TestScrollable()
    barController.preconfigure(scrollable: secondScrollable)

    XCTAssertEqual(secondScrollable._updateContentOffsetReceivedArgs?.0.y, -300)
    XCTAssertEqual(secondScrollable.contentInset.top, 300)
    XCTAssertEqual(secondScrollable.scrollIndicatorInsets.top, 200)
  }

  func testPreconfigureOnNormalState() {
    let scrollable = TestScrollable()
    barController.set(scrollable: scrollable)

    scrollable.contentOffset = CGPoint(x: 0, y: -200)

    let secondScrollable = TestScrollable()
    barController.preconfigure(scrollable: secondScrollable)

    XCTAssertEqual(secondScrollable._updateContentOffsetReceivedArgs?.0.y, -200)
    XCTAssertEqual(secondScrollable.contentInset.top, 200)
    XCTAssertEqual(secondScrollable.scrollIndicatorInsets.top, 200)
  }

  func testPreconfigureOnScrolledToBottomScrollable() {
    let scrollable = TestScrollable()
    barController.set(scrollable: scrollable)

    scrollable.contentOffset = CGPoint(x: 0, y: -200)

    let secondScrollable = TestScrollable()
    secondScrollable.contentOffset = CGPoint(x: 0, y: 500)
    barController.preconfigure(scrollable: secondScrollable)

    XCTAssertNil(secondScrollable._updateContentOffsetReceivedArgs)
    XCTAssertEqual(secondScrollable.contentInset.top, 200)
    XCTAssertEqual(secondScrollable.scrollIndicatorInsets.top, 200)
  }

  override func tearDown() {
    latestReceivedStateReducerParams = nil
    latestState = nil
  }
}
