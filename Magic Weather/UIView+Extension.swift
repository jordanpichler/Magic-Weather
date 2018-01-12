//
//  UIView+Extension.swift
//  Magic Weather
//
//  Created by Jordan Pichler on 12/01/2018.
//  Copyright © 2018 Jordan A. Pichler. All rights reserved.
//

import UIKit

extension UIView {
	func addConstraintsWithFormat(format: String, views: UIView...) {
		var viewsDictionary = [String: UIView]()
		for (index, view) in views.enumerated() {
			let key = "v\(index)"
			view.translatesAutoresizingMaskIntoConstraints = false
			viewsDictionary[key] = view
		}
		
		addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
	}
}
