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

  private var latestState: State?

  override func setUp() {
    stateReducer = { params -> State in
      return params.state
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

  override func tearDown() {
    latestState = nil
  }
}
