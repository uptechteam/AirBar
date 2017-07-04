//
//  BarController.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 6/23/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

import UIKit

public typealias StateObserver = (State) -> Void

public class BarController {
  
  private let stateReducer: StateReducer
  private let configuration: Configuration
  private let stateObserver: StateObserver

  private var state: State {
    didSet { stateObserver(state) }
  }
  
  private weak var scrollable: Scrollable?
  private var contentOffsetObservable: Observable<CGPoint>?
  private var contentSizeObservable: Observable<CGSize>?
  private var panGestureStateObservable: Observable<UIGestureRecognizerState>?
  private var isExpandedStateAvailable = false
  
  // MARK: - Lifecycle
  internal init(
    stateReducer: @escaping StateReducer,
    configuration: Configuration,
    stateObserver: @escaping StateObserver
  ) {
    self.stateReducer = stateReducer
    self.configuration = configuration
    self.stateObserver = stateObserver
    self.state = State(offset: -configuration.normalStateHeight, configuration: configuration)
  }
  
  public convenience init(
    configuration: Configuration,
    stateObserver: @escaping StateObserver
    ) {
    let middlewares = [ignoreTopDeltaYMiddleware, ignoreBottomDeltaYMiddleware]
    let stateReducer = createDefaultStateReducer(middlewares: middlewares)

    self.init(
      stateReducer: stateReducer,
      configuration: configuration,
      stateObserver: stateObserver
    )
  }
  
  // MARK: - Public Methods
  public func set(scrollView: UIScrollView) {
    self.set(scrollable: scrollView)
  }
  
  internal func set(scrollable: Scrollable) {
    self.scrollable = scrollable
    self.contentOffsetObservable = scrollable.contentOffsetObservable
    self.contentSizeObservable = scrollable.contentSizeObservable
    self.panGestureStateObservable = scrollable.panGestureStateObservable

    configureScrollable(scrollable)
    setupObserving()
  }
  
  // MARK: - Private Methods
  private func setupObserving() {
    // Content offset observing.
    var previousContentOffset: CGPoint?
    contentOffsetObservable?.observer = { [weak self] contentOffset in
      let contentOffset = CGPoint(x: contentOffset.x, y: contentOffset.y.rounded(.toNearestOrEven))
      self?.contentOffsetChanged(previousValue: previousContentOffset, newValue: contentOffset)
      previousContentOffset = contentOffset
    }
    
    // Content size observing.
    var previousContentSize: CGSize?
    contentSizeObservable?.observer = { [weak self] contentSize in
      self?.contentSizeChanged(previousValue: previousContentSize, newValue: contentSize)
      previousContentSize = contentSize
    }
    
    // Pan gesture state observing.
    panGestureStateObservable?.observer = { [weak self] state in
      self?.panGestureStateChanged(state: state)
    }
  }
  
  private func contentOffsetChanged(previousValue: CGPoint?, newValue: CGPoint) {
    guard
      let previousValue = previousValue,
      let scrollable = scrollable
    else {
      return
    }

    let reducerParams = StateReducerParameters(
      scrollable: scrollable,
      configuration: configuration,
      previousContentOffset: previousValue,
      contentOffset: newValue,
      isExpandedStateAvailable: isExpandedStateAvailable,
      state: state
    )

    state = stateReducer(reducerParams)
  }
  
  private func contentSizeChanged(previousValue: CGSize?, newValue: CGSize) {
    guard let scrollable = scrollable else { return }
    placeholdBottomInset(scrollable)
  }
  
  private func panGestureStateChanged(state: UIGestureRecognizerState) {
    switch state {
    case .began:
      panGestureBegan()
    case .ended:
      panGestureEnded()
    default:
      break
    }
  }

  private func panGestureBegan() {
    guard let scrollable = scrollable else { return }

    let isScrollingAtTop = scrollable.contentOffset.y.isNear(to: -configuration.normalStateHeight, delta: 5)
    let isExpandedStatePreviouslyAvailable = scrollable.contentOffset.y < -configuration.normalStateHeight && isExpandedStateAvailable
    isExpandedStateAvailable = isScrollingAtTop || isExpandedStatePreviouslyAvailable

    scrollable.updateTopContentInset(isExpandedStateAvailable ? configuration.expandedStateHeight : configuration.normalStateHeight)
  }

  private func panGestureEnded() {
    guard let scrollable = scrollable else { return }

    let stateProgress = state.transitionProgress()
    let roundedStateProgress = stateProgress.rounded(.toNearestOrEven)

    guard
      stateProgress != roundedStateProgress
    else {
      return
    }

    let stateRange: StateRange
    if stateProgress < 1 {
      stateRange = .compactNormal
    } else {
      stateRange = .normalExpanded
    }

    let progressDelta = roundedStateProgress - stateProgress
    let offsetBounds = configuration.offsetBounds(for: stateRange)
    let offsetBoundsDelta = offsetBounds.1 - offsetBounds.0
    let offsetDelta = progressDelta.map(from: (-1, 1), to: (-offsetBoundsDelta, offsetBoundsDelta))
    let targetContentOffsetY = scrollable.contentOffset.y - offsetDelta
    let targetContentOffset = CGPoint(x: scrollable.contentOffset.x, y: targetContentOffsetY)

    scrollable.updateContentOffset(targetContentOffset, animated: true)
  }

  private func configureScrollable(_ scrollable: Scrollable) {
    scrollable.updateTopContentInset(configuration.normalStateHeight)
    placeholdBottomInset(scrollable)
  }

  private func placeholdBottomInset(_ scrollable: Scrollable) {
    // Make sure that bar always expands and concats.
    let targetBottomContentInset: CGFloat
    if scrollable.contentSize.height < scrollable.frame.height - configuration.compactStateHeight {
      targetBottomContentInset = scrollable.frame.height - configuration.compactStateHeight - scrollable.contentSize.height
    } else {
      targetBottomContentInset = 0
    }

    scrollable.updateBottomContentInset(targetBottomContentInset)
  }
}
