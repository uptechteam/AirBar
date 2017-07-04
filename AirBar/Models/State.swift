//
//  State.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 7/4/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

public struct State {
  internal let offset: CGFloat
  internal let configuration: Configuration

  internal init(offset: CGFloat, configuration: Configuration) {
    self.offset = offset
    self.configuration = configuration
  }

  public func height() -> CGFloat {
    return -offset
  }

  public func stateRange() -> StateRange {
    if height() < configuration.normalStateHeight {
      return .compactNormal
    } else {
      return .normalExpanded
    }
  }

  public func transitionProgress() -> CGFloat {
    let stateRange = self.stateRange()
    let offsetBounds = configuration.offsetBounds(for: stateRange)
    let progressBounds = stateRange.progressBounds()
    let reversedProgressBounds = (progressBounds.1, progressBounds.0)
    return offset.map(from: offsetBounds, to: reversedProgressBounds)
  }
}

public enum StateRange {
  case compactNormal
  case normalExpanded

  func progressBounds() -> (CGFloat, CGFloat) {
    switch self {
    case .compactNormal:
      return (0, 1)
    case .normalExpanded:
      return (1, 2)
    }
  }
}
