//
//  UIScrollView+Helpers.swift
//  AirBar
//
//  Created by Evgeny Matviyenko on 2/27/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

import Foundation

extension UIScrollView {
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

  var bottomContentInset: CGFloat {
    get {
      return contentInset.bottom
    }

    set {
      contentInset = UIEdgeInsets(
        top: contentInset.top,
        left: contentInset.left,
        bottom: newValue,
        right: contentInset.right
      )
    }
  }
}
