//
//  AirBarController.swift
//  AirBar
//
//  Created by Evgeny Matviyenko on 2/24/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

import UIKit

public struct AirBarControllerConfiguration {
  public let normalStateHeight: CGFloat
  public let compactStateHeight: CGFloat?
  public let expandedStateHeight: CGFloat?

  public init(normalStateHeight: CGFloat, compactStateHeight: CGFloat? = nil, expandedStateHeight: CGFloat? = nil) {
    self.normalStateHeight = normalStateHeight
    self.compactStateHeight = compactStateHeight
    self.expandedStateHeight = expandedStateHeight

    if let compactStateHeight = compactStateHeight {
      assert(compactStateHeight < normalStateHeight, "Compact state height must be lower then normal state height.")
    }

    if let expandedStateHeight = expandedStateHeight {
      assert(normalStateHeight < expandedStateHeight, "Expanded state height must be bigger then normal state height.")
    }
  }

  func height(for state: AirBarState) -> CGFloat? {
    switch state {
    case .normal:
      return normalStateHeight
    case .compact:
      return compactStateHeight
    case .expanded:
      return expandedStateHeight
    }
  }
}

public protocol AirBarControllerDelegate: class {
  func airBarController(_ controller: AirBarController, didChangeStateTo state: CGFloat)
}

public class AirBarController: NSObject {

  // MARK: - Public Properties

  public weak var delegate: AirBarControllerDelegate? {
    didSet {
      // Send initial values.
      delegate?.airBarController(self, didChangeStateTo: state)
    }
  }

  // MARK: - Private Properties

  private var state = AirBarState.normal.rawValue {
    didSet {
      guard state != oldValue else {
        return
      }

      delegate?.airBarController(self, didChangeStateTo: state)
    }
  }
  
  private weak var scrollView: UIScrollView?

  private let configuration: AirBarControllerConfiguration

  private var previousYOffset: CGFloat?
  private var currentExpandedStateAvailability = false

  // KVO context.
  private var observerContext = 0

  // MARK: - Lifecycle

  public init(scrollView: UIScrollView, configuration: AirBarControllerConfiguration) {
    self.scrollView = scrollView
    self.configuration = configuration

    super.init()

    scrollView.topContentInset = configuration.normalStateHeight
    scrollView.scrollIndicatorInsets = UIEdgeInsets(top: configuration.normalStateHeight, left: 0, bottom: 0, right: 0)
    scrollView.setContentOffset(CGPoint(x: 0, y: -configuration.normalStateHeight), animated: false)

    setupScrollViewObserving()
  }

  deinit {
    scrollView?.panGestureRecognizer.removeTarget(self, action: #selector(handleScrollViewPanGesture(_:)))
    scrollView?.removeObserver(self, forKeyPath: "contentSize", context: &observerContext)
    scrollView?.removeObserver(self, forKeyPath: "contentOffset", context: &observerContext)
  }

  // MARK: - Internal Helpers

  private func panGestureBegan() {
    guard let scrollView = scrollView else { return }

    currentExpandedStateAvailability = (configuration.expandedStateHeight != nil && scrollView.contentOffset.y == -configuration.normalStateHeight) ||
      (currentExpandedStateAvailability && scrollView.contentOffset.y <= -configuration.normalStateHeight)

    if
      currentExpandedStateAvailability,
      let expandedStateHeight = configuration.expandedStateHeight
    {
      scrollView.topContentInset = expandedStateHeight
    } else {
      scrollView.topContentInset = configuration.normalStateHeight
    }
  }

  private func panGestureEnded() {
    guard
      let scrollView = scrollView,
      let roundedState = AirBarState(rawValue: state.rounded(.toNearestOrEven))
      else {
        return
    }

    if
      scrollView.contentOffset.y <= -configuration.normalStateHeight,
      let height = configuration.height(for: roundedState)
    {
      setContentOffset(CGPoint(x: 0, y: -height))
      return
    }

    let stateRemainder = state.truncatingRemainder(dividingBy: 1)
    if stateRemainder != 0,
      let compactStateHeight = configuration.compactStateHeight {
      let yOffsetDelta: CGFloat
      if stateRemainder < 0.5 {
        yOffsetDelta = (configuration.normalStateHeight - compactStateHeight) * stateRemainder
      } else {
        yOffsetDelta = -(configuration.normalStateHeight - compactStateHeight) * (1 - stateRemainder)
      }

      let newContentOffset = CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y + yOffsetDelta)
      setContentOffset(newContentOffset)
    }
  }

  private func scrollViewContentOffsetChanged(to contentOffset: CGPoint) {
    guard
      let scrollView = scrollView
    else {
      return
    }

    if
      currentExpandedStateAvailability,
      scrollView.contentOffset.y < -configuration.normalStateHeight,
      let expandedStateHeight = configuration.expandedStateHeight
    {
      state = contentOffset.y
        .map(
          from: (-expandedStateHeight, -configuration.normalStateHeight),
          to: (AirBarState.expanded.rawValue, AirBarState.normal.rawValue)
        )
        .bounded(by: (AirBarState.normal.rawValue, AirBarState.expanded.rawValue))

      return 
    }

    guard let compactStateHeight = configuration.compactStateHeight else { return }

    if let previousYOffset = previousYOffset {
      var deltaY = previousYOffset - scrollView.contentOffset.y

      let start = -scrollView.contentInset.top
      if previousYOffset < start {
        if deltaY < 0 {
          deltaY = min(0, deltaY - (previousYOffset - start))
        }
      }

      let end = (scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom - CGFloat(0.5)).rounded(.down)
      if previousYOffset > end && deltaY > 0 {
        deltaY = max(0, deltaY - previousYOffset + end)
      }

      let compactNormalDelta = configuration.normalStateHeight - compactStateHeight
      let stateDelta = AirBarState.normal.rawValue - AirBarState.compact.rawValue
      let deltaState = deltaY.map(from: (-compactNormalDelta, compactNormalDelta), to: (-stateDelta, stateDelta))
      let newState = state + deltaState
      state = newState.bounded(by: (AirBarState.compact.rawValue, AirBarState.normal.rawValue))
    }

    previousYOffset = contentOffset.y
  }

  private func scrollViewContentSizeChanged(to contentSize: CGSize) {

  }

  private func setContentOffset(_ contentOffset: CGPoint, animated: Bool = true) {
    guard let scrollView = scrollView else { return }

    // Stop native deceleration. 
    scrollView.setContentOffset(scrollView.contentOffset, animated: false)

    let animate = {
      scrollView.contentOffset = contentOffset
    }

    guard animated else {
      animate()
      return
    }

    UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: animate, completion: nil)
  }

  // MARK: - Observing

  private func setupScrollViewObserving() {
    guard let scrollView = scrollView else { return }

    scrollView.panGestureRecognizer.addTarget(self, action: #selector(handleScrollViewPanGesture(_:)))
    scrollView.addObserver(self, forKeyPath: "contentSize", options: [.initial, .new], context: &observerContext)
    scrollView.addObserver(self, forKeyPath: "contentOffset", options: [.initial, .new], context: &observerContext)
  }

  @objc private func handleScrollViewPanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
    switch gestureRecognizer.state {
    case .began:
      panGestureBegan()
    case .ended:
      panGestureEnded()
    default:
      break
    }
  }

  override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard context == &observerContext else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
      return
    }

    if keyPath == "contentOffset",
      let contentOffset = (change?[.newKey] as? NSValue)?.cgPointValue
    {
      // ContentOffset
      scrollViewContentOffsetChanged(to: contentOffset)
    } else if keyPath == "contentSize",
      let contentSize = (change?[.newKey] as? NSValue)?.cgSizeValue
    {
      // ContentSize
      scrollViewContentSizeChanged(to: contentSize)
    }
  }

}

// MARK: - UIScrollView+Helpers

private extension UIScrollView {
  var topContentInset: CGFloat {
    get {
      return contentInset.top
    }

    set {
      contentInset = UIEdgeInsets(
        top: newValue,
        left: contentInset.left,
        bottom: contentInset.bottom,
        right: contentInset.right
      )
    }
  }
}

// MARK: - CGFloat+Helpers

private extension CGFloat {
  func map(from firstBounds: (CGFloat, CGFloat), to secondBounds: (CGFloat, CGFloat)) -> CGFloat {
    guard self > firstBounds.0 else {
      return secondBounds.0
    }

    guard self < firstBounds.1 else {
      return secondBounds.1
    }

    let firstBoundsDelta = firstBounds.1 - firstBounds.0
    let ratio = (self - firstBounds.0) / firstBoundsDelta
    return secondBounds.0 + ratio * (secondBounds.1 - secondBounds.0)
  }

  func bounded(by bounds: (CGFloat, CGFloat)) -> CGFloat {
    return Swift.max(bounds.0, Swift.min(bounds.1, self))
  }
  
}
