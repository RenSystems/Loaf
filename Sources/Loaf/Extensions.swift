//
//  Extensions.swift
//  Loaf
//
//  Created by Mat Schmid on 2019-02-04.
//  Copyright © 2019 Mat Schmid. All rights reserved.
//

import UIKit

extension UIViewController {
    func present(_ notification: LoafViewController) {
        notification.loadViewIfNeeded()
        notification.transDelegate = Manager(loaf: notification.loaf, size: notification.preferredContentSize)
        notification.transitioningDelegate = notification.transDelegate
        notification.modalPresentationStyle = .custom
        present(notification, animated: true)
    }
}

extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
}
