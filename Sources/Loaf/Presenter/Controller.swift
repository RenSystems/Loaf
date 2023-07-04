//
//  Controller.swift
//  Loaf
//
//  Created by Mat Schmid on 2019-02-05.
//  Copyright © 2019 Mat Schmid. All rights reserved.
//

import UIKit

final class Controller: UIPresentationController {
    private let loaf: Loaf
    private let size: () -> CGSize
    
    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        loaf: Loaf,
        size: @escaping () -> CGSize) {
        
        self.loaf = loaf
        self.size = size
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    //MARK: - Transitions
    
    override func containerViewWillLayoutSubviews() {
        presentedViewController.viewWillLayoutSubviews()
        layoutContainerView()
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func presentationTransitionWillBegin() {
        layoutContainerView()
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return size()
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        let containerSize = size(forChildContentContainer: presentedViewController,
                                 withParentContainerSize: containerView.bounds.size)
        
        let yPosition: CGFloat
        switch loaf.location {
        case .bottom:
            yPosition = containerView.bounds.height - containerSize.height
        case .top:
            yPosition = 0
        }
        
        let toastSize = CGRect(x: containerView.center.x - (containerSize.width / 2),
                               y: yPosition,
                               width: containerSize.width,
                               height: containerSize.height
        )
        
        return toastSize
    }
    
    func layoutContainerView() {
        guard let containerView else {
            return
        }
        
        var containerInsets: UIEdgeInsets
        
        if loaf.style.contentOffset != .zero {
            containerInsets = loaf.style.contentOffset
        } else {
            if #available(iOS 11, *) {
                containerInsets = containerView.safeAreaInsets
            } else {
                let statusBarSize = UIApplication.shared.statusBarFrame.size
                containerInsets = UIEdgeInsets(top: min(statusBarSize.width, statusBarSize.height), left: 0, bottom: 0, right: 0)
            }
            
            if let tabBar = loaf.sender?.parent as? UITabBarController{
                containerInsets.bottom += tabBar.tabBar.frame.height
            }
        }

        let prettyfierInset = CGFloat(10)
        if containerInsets.bottom == 0 {
            containerInsets.bottom += prettyfierInset
        }
        containerInsets.top += prettyfierInset

        let yPosition: CGFloat
        switch loaf.location {
        case .bottom:
            yPosition = containerView.frame.origin.y + containerView.frame.height - size().height - containerInsets.bottom
        case .top:
            yPosition = containerInsets.top
        }
        
        let origin = CGPoint(
            x: 0,
            y: yPosition
        )
        
        containerView.frame.origin = origin
        containerView.frame.size.height = size().height
        containerView.frame.size.width = self.presentingViewController.view.frame.width
    }
}
