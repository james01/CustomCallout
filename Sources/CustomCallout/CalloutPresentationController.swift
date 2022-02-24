//
//  CalloutPresentationController.swift
//  
//
//  Created by James Randolph on 2/23/22.
//

import UIKit

extension CGRect {
    init(center: CGPoint, size: CGSize) {
        let origin = CGPoint(x: center.x - size.width/2, y: center.y - size.height/2)
        self.init(origin: origin, size: size)
    }

    func offsetToFitInside(_ containingRect: CGRect) -> CGRect {
        let dx = max(containingRect.minX - minX, 0) - max(maxX - containingRect.maxX, 0)
        let dy = max(containingRect.minY - minY, 0) - max(maxY - containingRect.maxY, 0)
        return offsetBy(dx: dx, dy: dy)
    }
}

class CalloutPresentationController: UIPresentationController {

    let sourceView: UIView

    var interactor: UIPercentDrivenInteractiveTransition?

    let chromeView = UIView()

    var preferredPlacements: [CalloutPosition.PreferredPlacement] = [.top, .bottom, .horizontal]

    let calloutView = CalloutBackgroundView()

    override var presentedView: UIView? {
        return calloutView
    }

    var calloutPosition: CalloutPosition = .unknown

    override var frameOfPresentedViewInContainerView: CGRect {
        return calloutPosition.frame
    }

    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, sourceView: UIView) {
        self.sourceView = sourceView
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

        chromeView.backgroundColor = UIColor.black.withAlphaComponent(0.04)
        chromeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chromeViewTapped)))
    }

    func positionForCallout(ofSize calloutSize: CGSize) -> CalloutPosition {
        guard let containerView = containerView else { return .unknown }
        containerView.layoutMargins = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        let layoutFrame = containerView.bounds.inset(by: containerView.layoutMargins)

        let arrowInset = 6 - CalloutBackgroundView.arrowHeight()
        let arrowEdgeInsets = UIEdgeInsets(top: arrowInset, left: arrowInset, bottom: arrowInset, right: arrowInset)
        let sourceRelative = sourceView.frame.inset(by: arrowEdgeInsets).offsetBy(dx: -layoutFrame.origin.x, dy: -layoutFrame.origin.y)

        func layoutSlice(for placement: CalloutPosition.PreferredPlacement) -> (slice: CGRect, placement: CalloutPosition.ResolvedPlacement) {
            switch placement {
            case .top:
                return (layoutFrame.divided(atDistance: sourceRelative.minY, from: .minYEdge).slice, .top)
            case .bottom:
                return (layoutFrame.divided(atDistance: sourceRelative.maxY, from: .minYEdge).remainder, .bottom)
            case .horizontal:
                let leftFrame = layoutFrame.divided(atDistance: sourceRelative.minX, from: .minXEdge).slice
                let rightFrame = layoutFrame.divided(atDistance: sourceRelative.maxX, from: .minXEdge).remainder
                return (leftFrame.width > rightFrame.width) ? (leftFrame, .left) : (rightFrame, .right)
            }
        }

        func arrowOffsetForCallout(withFrame calloutFrame: CGRect, placement: CalloutPosition.ResolvedPlacement) -> CGFloat {
            switch placement {
            case .top, .bottom:
                return sourceView.frame.midX - calloutFrame.midX
            case .left, .right:
                return sourceView.frame.midY - calloutFrame.midY
            case .unknown:
                return 0
            }
        }

        let layoutSlices = preferredPlacements.map(layoutSlice(for:))

        for (layoutSlice, placement) in layoutSlices {
            if (layoutSlice.width >= calloutSize.width) && (layoutSlice.height >= calloutSize.height) {
                let calloutFrame = CGRect(center: sourceView.center, size: calloutSize).offsetToFitInside(layoutSlice)
                let arrowOffset = arrowOffsetForCallout(withFrame: calloutFrame, placement: placement)
                return CalloutPosition(frame: calloutFrame, placement: placement, arrowOffset: arrowOffset)
            }
        }

        return layoutSlices
            .map({
                let calloutFrame = CGRect(center: sourceView.center, size: calloutSize).offsetToFitInside($0.slice).intersection($0.slice)
                let arrowOffset = arrowOffsetForCallout(withFrame: calloutFrame, placement: $0.placement)
                return CalloutPosition(frame: calloutFrame, placement: $0.placement, arrowOffset: arrowOffset)
            })
            .max(by: { ($0.frame.width * $0.frame.height) < ($1.frame.width * $1.frame.height) }) ?? .unknown
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        presentedViewController.dismiss(animated: false, completion: nil)
        coordinator.animate(alongsideTransition: nil) { [self] _ in
            presentingViewController.present(presentedViewController, animated: true, completion: nil)
        }
    }

    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        guard container === presentedViewController else { return }
        guard !presentedViewController.isBeingPresented else { return }
        calloutPosition = positionForCallout(ofSize: container.preferredContentSize)
        calloutView.setAnchorPoint(forPosition: calloutPosition)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: { [self] in
            calloutView.frame = calloutPosition.frame
            calloutView.setArrowOffset(forPosition: calloutPosition)
            calloutView.layoutIfNeeded()
        }, completion: nil)
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        calloutPosition = positionForCallout(ofSize: presentedViewController.preferredContentSize)

        chromeView.alpha = 0
        chromeView.frame = containerView.bounds
        chromeView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(chromeView)

        calloutView.setAnchorPoint(forPosition: calloutPosition)
        calloutView.setArrowOffset(forPosition: calloutPosition)
        presentedViewController.view.frame = calloutView.bounds
        presentedViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        calloutView.addSubview(presentedViewController.view)

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [self] (ctx) in
            chromeView.alpha = 1
        }, completion: nil)
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            chromeView.removeFromSuperview()
        }
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [self] (ctx) in
            chromeView.alpha = 0
        }, completion: nil)
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            chromeView.removeFromSuperview()
        }
    }

    @objc func chromeViewTapped() {
        if presentedViewController.isBeingPresented {
            interactor?.cancel()
        } else if !presentedViewController.isBeingDismissed {
            presentedViewController.dismiss(animated: true, completion: nil)
        }
    }
}
