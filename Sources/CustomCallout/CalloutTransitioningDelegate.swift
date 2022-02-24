//
//  CalloutTransitioningDelegate.swift
//  
//
//  Created by James Randolph on 2/23/22.
//

import UIKit

public class CalloutTransitioningDelegate: NSObject {

    private let sourceView: UIView

    private let interactor = UIPercentDrivenInteractiveTransition()

    public init(sourceView: UIView) {
        self.sourceView = sourceView
    }
}

extension CalloutTransitioningDelegate: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CalloutAnimator(isPresenting: true)
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CalloutAnimator(isPresenting: false)
    }

    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        interactor.wantsInteractiveStart = false
        return interactor
    }

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let calloutController = CalloutPresentationController(presentedViewController: presented, presenting: presenting, sourceView: sourceView)
        calloutController.interactor = interactor
        return calloutController
    }
}
