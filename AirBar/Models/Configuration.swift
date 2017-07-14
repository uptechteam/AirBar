//
//  Configuration.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 6/23/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

public struct Configuration {
  let compactStateHeight: CGFloat
  let normalStateHeight: CGFloat
  let expandedStateHeight: CGFloat

  internal func offsetBounds(for stateRange: StateRange) -> (CGFloat, CGFloat) {
    switch stateRange {
    case .compactNormal:
      return (-normalStateHeight, -compactStateHeight)
    case .normalExpanded:
      return (-expandedStateHeight, -normalStateHeight)
    }
  }
}

extension Configuration: Equatable {
  public static func == (lhs: Configuration, rhs: Configuration) -> Bool {
    return lhs.compactStateHeight == rhs.compactStateHeight &&
      lhs.normalStateHeight == rhs.normalStateHeight &&
      lhs.expandedStateHeight == rhs.expandedStateHeight
  }
}
