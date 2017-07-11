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

  internal func stateRange() -> StateRange {
    if offset > -configuration.normalStateHeight {
      return .compactNormal
    } else {
      return .normalExpanded
    }
  }

  internal func set(offset: CGFloat) -> State {
    return State(offset: offset, configuration: configuration)
  }

  internal func add(offset: CGFloat) -> State {
    return set(offset: self.offset + offset)
  }
}

public extension State {
  public func height() -> CGFloat {
    return -offset
  }

  public func transitionProgress() -> CGFloat {
    let stateRange = self.stateRange()
    let offsetBounds = configuration.offsetBounds(for: stateRange)
    let progressBounds = stateRange.progressBounds()
    let reversedProgressBounds = (progressBounds.1, progressBounds.0)
    return offset.map(from: offsetBounds, to: reversedProgressBounds)
  }
}

extension State: Equatable {
  public static func == (lhs: State, rhs: State) -> Bool {
    return lhs.offset == rhs.offset &&
      lhs.configuration == rhs.configuration
  }
}
