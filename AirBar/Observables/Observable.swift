//
//  Observable.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 6/23/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

internal class Observable<Value>: NSObject {
  internal var observer: ((Value) -> Void)?
}
