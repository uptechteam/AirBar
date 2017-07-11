//
//  KVObservableTests.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 7/11/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

import XCTest
@testable import AirBar

private class TestObject: NSObject {
  dynamic var property: Int = 0
}

class KVObservableTests: XCTestCase {
  private var testObject: TestObject!
  private var propertyObservable: KVObservable<Int>!

  override func setUp() {
    super.setUp()

    testObject = TestObject()
    propertyObservable = KVObservable(keyPath: #keyPath(TestObject.property), object: testObject)
  }

  func testEmmitsValueWhenPropertyChanges() {
    var receivedValue: Int?
    propertyObservable.observer = { newValue in
      receivedValue = newValue
    }

    testObject.property = 10
    XCTAssertEqual(receivedValue, 10)

    testObject.property = 200
    XCTAssertEqual(receivedValue, 200)
  }
}
