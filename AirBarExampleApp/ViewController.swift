//
//  ViewController.swift
//  AirBarExampleApp
//
//  Created by Evgeny Matviyenko on 2/24/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

import AirBar
import UIKit

class ViewController: UIViewController {

  // MARK: - Outlets

  @IBOutlet weak var tableView: UITableView!

  // MARK: - Private Properties

  fileprivate var airBar: UIView!
  fileprivate var backgroundView: UIView!
  fileprivate var darkMenuView: MenuView!
  fileprivate var lightMenuView: MenuView!
  fileprivate var normalView: NormalView!
  fileprivate var expandedView: UIView!
  fileprivate var backButton: UIButton!
  fileprivate var airBarController: AirBarController!

  fileprivate var shouldHideStatusBar = false {
    didSet {
      guard shouldHideStatusBar != oldValue else { return }
      updateStatusBar()
    }
  }

  fileprivate var prefersStatusBarStyle = UIStatusBarStyle.lightContent {
    didSet {
      guard prefersStatusBarStyle != oldValue else { return }
      updateStatusBar()
    }
  }

  private enum Constants {
    static let normalStateHeight: CGFloat = 128
    static let compactStateHeight: CGFloat = 64
    static let expandedStateHeight: CGFloat = 284
  }

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.dataSource = self

    backgroundView = UIImageView(image: #imageLiteral(resourceName: "grad"))

    darkMenuView = UINib(nibName: "MenuView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! MenuView
    darkMenuView.setStyle(light: false)
    lightMenuView = UINib(nibName: "MenuView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! MenuView
    lightMenuView.setStyle(light: true)

    normalView = UINib(nibName: "NormalView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! NormalView
    normalView.clipsToBounds = true
    normalView.searchTapGestureRecognizer.addTarget(self, action: #selector(handleSearchViewTapped(_:)))

    expandedView = UINib(nibName: "ExpandedView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! UIView
    expandedView.clipsToBounds = true

    backButton = UIButton(frame: CGRect(x: 22, y: 34, width: 40, height: 40))
    backButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
    backButton.imageEdgeInsets = UIEdgeInsets(top: 14, left: 10, bottom: 14, right: 10)
    backButton.addTarget(self, action: #selector(self.handleBackButtonPressed(_:)), for: .touchUpInside)

    airBar = UIView()
    airBar.backgroundColor = UIColor.white
    airBar.layer.masksToBounds = false
    airBar.layer.shadowRadius = 4
    airBar.layer.shadowOpacity = 0.35
    airBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)

    airBar.addSubview(backgroundView)
    airBar.addSubview(darkMenuView)
    airBar.addSubview(lightMenuView)
    airBar.addSubview(normalView)
    airBar.addSubview(expandedView)
    airBar.addSubview(backButton)
    view.addSubview(airBar)

    let configuration = AirBarControllerConfiguration(
      normalStateHeight: Constants.normalStateHeight,
      compactStateHeight: Constants.compactStateHeight,
      expandedStateHeight: Constants.expandedStateHeight,
      initialState: .normal
    )
    airBarController = AirBarController(scrollView: tableView, configuration: configuration)
    airBarController.delegate = self
  }

  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)

    coordinator.animate(alongsideTransition: { _ in
      self.airBar.frame = CGRect(x: self.airBar.frame.minX, y: self.airBar.frame.minY, width: size.width, height: self.airBar.frame.height)
      self.backgroundView.frame = CGRect(x: self.backgroundView.frame.minX, y: self.backgroundView.frame.minY, width: size.width, height: self.backgroundView.frame.height)
      self.normalView.frame = CGRect(x: self.normalView.frame.minX, y: self.normalView.frame.minY, width: size.width, height: self.normalView.frame.height)
      self.expandedView.frame = CGRect(x: self.expandedView.frame.minX, y: self.expandedView.frame.minY, width: size.width, height: self.expandedView.frame.height)
    }, completion: nil)
  }

  // MARK: - Status Bar

  override var prefersStatusBarHidden: Bool {
    return shouldHideStatusBar
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return prefersStatusBarStyle
  }

  override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    return .fade
  }

  private func updateStatusBar() {
    UIView.animate(withDuration: 0.20, delay: 0, options: .curveEaseInOut, animations: {
      self.setNeedsStatusBarAppearanceUpdate()
    }, completion: nil)
  }

  // MARK: - User Interaction

  @objc private func handleBackButtonPressed(_ button: UIButton) {
    airBarController.expand(on: false)
  }

  @objc private func handleSearchViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
    airBarController.expand(on: true)
  }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 20
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
  }
}

// MARK: - AirBarControllerDelegate

extension ViewController: AirBarControllerDelegate {
  func airBarController(_ controller: AirBarController, didChangeStateTo state: CGFloat, withHeight height: CGFloat) {

    shouldHideStatusBar = state > 0 && state < 1
    prefersStatusBarStyle = state > 0.5 ? .lightContent : .default

    let airBarFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: height)
    let backgroundViewAlpha: CGFloat
    let normalViewY: CGFloat
    let normalViewAlpha: CGFloat
    let expandedViewY: CGFloat
    let expandedViewAlpha: CGFloat
    let backButtonAlpha: CGFloat
    let lightMenuViewAlpha: CGFloat
    let darkMenuViewAlpha: CGFloat
    let menuViewY: CGFloat = height - 40

    if state < 1 {
      backgroundViewAlpha = state
      normalViewY = state.map(from: (0, 1), to: (-24, 40))
      normalViewAlpha = state
      expandedViewY = 40
      expandedViewAlpha = 0
      backButtonAlpha = 0
      lightMenuViewAlpha = state.map(from: (0, 1), to: (0, 1))
      darkMenuViewAlpha = state.map(from: (0, 1), to: (1, 0))
    } else {
      backgroundViewAlpha = 1
      normalViewY = state.map(from: (1, 2), to: (40, 80))
      normalViewAlpha = state.map(from: (1, 2), to: (1, 0))
      expandedViewY = state.map(from: (1, 2), to: (40, 80))
      expandedViewAlpha = state.map(from: (1, 2), to: (0, 1))
      backButtonAlpha = state.map(from: (1.5, 2), to: (0, 1))
      lightMenuViewAlpha = 1
      darkMenuViewAlpha = 0
    }

    airBar.frame = airBarFrame
    backgroundView.frame = airBarFrame
    backgroundView.alpha = backgroundViewAlpha
    normalView.frame = CGRect(x: 0, y: normalViewY, width: view.frame.width, height: height - normalViewY - (height - menuViewY))
    normalView.alpha = normalViewAlpha
    expandedView.frame = CGRect(x: 0, y: expandedViewY, width: view.frame.width, height: height - expandedViewY - (height - menuViewY))
    expandedView.alpha = expandedViewAlpha
    backButton.alpha = backButtonAlpha
    lightMenuView.alpha = lightMenuViewAlpha
    darkMenuView.alpha = darkMenuViewAlpha
    lightMenuView.frame = CGRect(x: 0, y: menuViewY, width: view.frame.width, height: 40)
    darkMenuView.frame = lightMenuView.frame
  }
}
