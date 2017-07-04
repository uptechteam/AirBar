//
//  DelegateContentOffsetObservable.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 7/3/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

import UIKit

class DelegateContentOffsetObservable: Observable<CGPoint>, UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    observer?(scrollView.contentOffset)
  }
}
