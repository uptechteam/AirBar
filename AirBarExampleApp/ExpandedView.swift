//
//  ExpandedView.swift
//  AirBar
//
//  Created by Evgeny Matviyenko on 3/1/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

import UIKit

class ExpandedView: UIView {
  @IBOutlet weak var placeContainerView: UIView!
  @IBOutlet weak var timeContainerView: UIView!
  @IBOutlet weak var guestsContainerView: UIView!

  private struct Constants {
    static let containerSideInset: CGFloat = 20
    static let containerHeight: CGFloat = 42
    static let containersInset: CGFloat = 8
    static let totalHeight: CGFloat = 150
  }

  private var viewIsLoaded = false

  override var frame: CGRect {
    didSet {
      guard viewIsLoaded else { return }
      
      let containersInset = frame.height.map(from: (0, Constants.totalHeight), to: (0, Constants.containersInset))
      let containersSize = CGSize(width: max(0, frame.width - (Constants.containerSideInset * 2)), height: Constants.containerHeight)
      let containersX = Constants.containerSideInset

      placeContainerView.frame = CGRect(origin: CGPoint(x: containersX, y: 0), size: containersSize)
      timeContainerView.frame = CGRect(origin: CGPoint(x: containersX, y: placeContainerView.frame.maxY + containersInset), size: containersSize)
      guestsContainerView.frame = CGRect(origin: CGPoint(x: containersX, y: timeContainerView.frame.maxY + containersInset), size: containersSize)
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()

    viewIsLoaded = true
  }

}
