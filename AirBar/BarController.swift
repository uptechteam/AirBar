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
    let transformers: [ContentOffsetDeltaYTransformer] = [
      ignoreTopDeltaYTransformer,
      ignoreBottomDeltaYTransformer,
      cutOutStateRangeDeltaYTransformer,
    ]
    let stateReducer = makeDefaultStateReducer(transformers: transformers)

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

    preconfigure(scrollable: scrollable)
    setupObserving()
  }

  public func preconfigure(scrollView: UIScrollView) {
    preconfigure(scrollable: scrollView)
  }

  internal func preconfigure(scrollable: Scrollable) {
    scrollable.setBottomContentInsetToFillEmptySpace(heightDelta: configuration.compactStateHeight)

    let isExpandedState = state.offset < -configuration.normalStateHeight && isExpandedStateAvailable

    scrollable.contentInset.top = isExpandedState ? configuration.expandedStateHeight : configuration.normalStateHeight
    scrollable.scrollIndicatorInsets.top = configuration.normalStateHeight

    let currentContentOffsetY = scrollable.contentOffset.y
    if currentContentOffsetY <= 0 || isExpandedState {
      let targetContentOffset = CGPoint(x: scrollable.contentOffset.x, y: state.offset)
      scrollable.updateContentOffset(targetContentOffset, animated: false)
    }
  }

  public func expand(on: Bool) {
    guard let scrollable = scrollable else { return }

    if on { self.isExpandedStateAvailable = true }

    let targetContentOffsetY = on ? -configuration.expandedStateHeight : -configuration.normalStateHeight
    let targetContentOffset = CGPoint(x: scrollable.contentOffset.x, y: targetContentOffsetY)
    scrollable.updateContentOffset(targetContentOffset, animated: true)

    let targetTopContentInset = on ? configuration.expandedStateHeight : configuration.normalStateHeight
    scrollable.contentInset.top = targetTopContentInset
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

  // MARK: Scroll View Handlers
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

    scrollable.setBottomContentInsetToFillEmptySpace(heightDelta: configuration.compactStateHeight)

    if scrollable.contentSize.height - state.offset < scrollable.frame.height {
      let targetContentOffset = CGPoint(x: scrollable.contentOffset.x, y: state.offset)
      scrollable.updateContentOffset(targetContentOffset, animated: false)
    }
  }

  // MARK: Pan Gesture Handlers
  private func panGestureStateChanged(state: UIGestureRecognizerState) {
    switch state {
    case .began:
      panGestureBegan()
    case .ended:
      panGestureEnded()
    case .changed:
      panGestureChanged()
    default:
      break
    }
  }

  private func panGestureBegan() {
    guard let scrollable = scrollable else { return }

    let isScrollingAtTop = scrollable.contentOffset.y.isNear(to: -configuration.normalStateHeight, delta: 5)
    let isExpandedStatePreviouslyAvailable = scrollable.contentOffset.y < -configuration.normalStateHeight && isExpandedStateAvailable
    isExpandedStateAvailable = isScrollingAtTop || isExpandedStatePreviouslyAvailable

    scrollable.contentInset.top = isExpandedStateAvailable ? configuration.expandedStateHeight : configuration.normalStateHeight
  }

  private func panGestureChanged() {
    guard let scrollable = scrollable else { return }

    if isExpandedStateAvailable {
      if scrollable.contentOffset.y > -configuration.normalStateHeight {
        isExpandedStateAvailable = false
        scrollable.contentInset.top = configuration.normalStateHeight
      }
    }
  }

  private func panGestureEnded() {
    guard let scrollable = scrollable else { return }

    let stateOffset = state.offset
    let offsets = [
      -configuration.compactStateHeight,
      -configuration.normalStateHeight,
      -configuration.expandedStateHeight
    ]

    let smallestDelta = offsets.reduce(nil) { (smallestDelta: CGFloat?, offset: CGFloat) -> CGFloat in
      let delta = offset - stateOffset
      guard let smallestDelta = smallestDelta else { return delta }
      return abs(delta) < abs(smallestDelta) ? delta : smallestDelta
    }

    if let smallestDelta = smallestDelta, smallestDelta != 0 {
      let targetContentOffsetY = scrollable.contentOffset.y + smallestDelta
      let targetContentOffset = CGPoint(x: scrollable.contentOffset.x, y: targetContentOffsetY)
      scrollable.updateContentOffset(targetContentOffset, animated: true)
    }
  }
}
