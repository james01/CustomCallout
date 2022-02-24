//
//  CalloutAnimator.swift
//  
//
//  Created by James Randolph on 2/23/22.
//

import UIKit

class CalloutAnimator: NSObject {

    let isPresenting: Bool

    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
    }
}

extension CalloutAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using ctx: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using ctx: UIViewControllerContextTransitioning) {
        let presentedViewController = ctx.viewController(forKey: isPresenting ? .to : .from)!
        let presentedView = ctx.view(forKey: isPresenting ? .to : .from)!

        let scale: CGFloat = 0.8

        if isPresenting {
            presentedView.frame = ctx.finalFrame(for: presentedViewController)
            ctx.containerView.addSubview(presentedView)
            presentedView.alpha = 0
            presentedView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }

        UIView.animate(withDuration: transitionDuration(using: ctx), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.allowUserInteraction]) { [self] in
            presentedView.alpha = isPresenting ? 1 : 0
            presentedView.transform = isPresenting ? .identity : CGAffineTransform(scaleX: scale, y: scale)
        } completion: { (_) in
            ctx.completeTransition(!ctx.transitionWasCancelled)
        }
    }
}
