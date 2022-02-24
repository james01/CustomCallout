//
//  CalloutBackgroundView.swift
//  
//
//  Created by James Randolph on 2/23/22.
//

import UIKit

class CalloutBackgroundView: UIView, UIPopoverBackgroundViewMethods {

    class func arrowBase() -> CGFloat {
        return 24
    }

    class func arrowHeight() -> CGFloat {
        return 12
    }

    class func contentViewInsets() -> UIEdgeInsets {
        return .zero
    }

    let arrowView = UIImageView()

    let arrowInnerShadowView = UIImageView()

    let innerShadowColor = UIColor.black.withAlphaComponent(0.06)

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Outer shadow 1
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 2
        layer.shadowOffset = .zero

        // Inner shadow
        let innerShadowImage = UIImage(named: "callout_inner_shadow", in: .module, with: nil)?.resizableImage(withCapInsets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)).withTintColor(innerShadowColor)
        let innerShadowView = UIImageView(image: innerShadowImage)
        innerShadowView.frame = bounds
        innerShadowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(innerShadowView)

        // Outer shadow 2
        innerShadowView.layer.shadowColor = UIColor.black.cgColor
        innerShadowView.layer.shadowOpacity = 0.06
        innerShadowView.layer.shadowRadius = 10
        innerShadowView.layer.shadowOffset = CGSize(width: 0, height: 4)

        // Background color
        innerShadowView.backgroundColor = .systemBackground

        // Round corners
        innerShadowView.layer.cornerRadius = 16
        innerShadowView.layer.cornerCurve = .continuous

        // Arrow
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        let arrowImage = UIImage(named: "callout_arrow", in: .module, with: nil)?.withTintColor(.systemBackground)
        arrowView.image = arrowImage
        if let arrowImageHeight = arrowImage?.size.height {
            arrowView.layer.anchorPoint = CGPoint(x: 0.5, y: 1 - (CalloutBackgroundView.arrowHeight()/arrowImageHeight))
        }
        addSubview(arrowView)

        // Arrow inner shadow
        arrowInnerShadowView.frame = arrowView.bounds
        arrowInnerShadowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        arrowView.addSubview(arrowInnerShadowView)

        setArrowOffset(forPosition: .unknown)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Sets the arrow offset and placement for the given callout position.
    /// - Parameter position: The callout position.
    func setArrowOffset(forPosition position: CalloutPosition) {
        arrowView.isHidden = (position.placement == .unknown)
        arrowView.removeConstraints(arrowView.constraints)

        switch position.placement {
        case .top:
            arrowView.transform = .identity
            NSLayoutConstraint.activate([
                arrowView.centerYAnchor.constraint(equalTo: bottomAnchor),
                arrowView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: position.arrowOffset)
            ])
            arrowInnerShadowView.image = UIImage(named: "callout_arrow_inner_shadow_bottom", in: .module, with: nil)?.withTintColor(innerShadowColor)
        case .bottom:
            arrowView.transform = CGAffineTransform(scaleX: 1, y: -1)
            NSLayoutConstraint.activate([
                arrowView.centerYAnchor.constraint(equalTo: topAnchor),
                arrowView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: position.arrowOffset)
            ])
            arrowInnerShadowView.image = nil
        case .left:
            arrowView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
            NSLayoutConstraint.activate([
                arrowView.centerXAnchor.constraint(equalTo: rightAnchor),
                arrowView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: position.arrowOffset)
            ])
            arrowInnerShadowView.image = UIImage(named: "callout_arrow_inner_shadow_right", in: .module, with: nil)?.withTintColor(innerShadowColor)
        case .right:
            arrowView.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
            NSLayoutConstraint.activate([
                arrowView.centerXAnchor.constraint(equalTo: leftAnchor),
                arrowView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: position.arrowOffset)
            ])
            arrowInnerShadowView.image = UIImage(named: "callout_arrow_inner_shadow_right", in: .module, with: nil)?.withHorizontallyFlippedOrientation().withTintColor(innerShadowColor)
        case .unknown:
            break
        }
    }

    /// Sets the anchor point to the tip of the callout arrow. This is helpful for implementing scaling transformations, for example.
    /// - Parameter position: The callout position.
    func setAnchorPoint(forPosition position: CalloutPosition) {
        let anchorPoint: CGPoint
        switch position.placement {
        case .top:
            let anchorX = 0.5 + (position.arrowOffset / position.frame.width)
            let anchorY = 1 + (CalloutBackgroundView.arrowHeight() / position.frame.height)
            anchorPoint = CGPoint(x: anchorX, y: anchorY)
        case .bottom:
            let anchorX = 0.5 + (position.arrowOffset / position.frame.width)
            let anchorY = -(CalloutBackgroundView.arrowHeight() / position.frame.height)
            anchorPoint = CGPoint(x: anchorX, y: anchorY)
        case .left:
            let anchorX = 1 + (CalloutBackgroundView.arrowHeight() / position.frame.width)
            let anchorY = 0.5 + (position.arrowOffset / position.frame.height)
            anchorPoint = CGPoint(x: anchorX, y: anchorY)
        case .right:
            let anchorX = -(CalloutBackgroundView.arrowHeight() / position.frame.width)
            let anchorY = 0.5 + (position.arrowOffset / position.frame.height)
            anchorPoint = CGPoint(x: anchorX, y: anchorY)
        case .unknown:
            anchorPoint = CGPoint(x: 0.5, y: 0.5)
        }

        setAnchorPoint(anchorPoint)
    }

    /// Sets the anchor point without affecting the position of the view.
    /// - Parameter point: The new anchor point.
    func setAnchorPoint(_ point: CGPoint) {
        var newPoint = CGPoint(x: bounds.size.width * point.x, y: bounds.size.height * point.y)
        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y);

        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)

        var position = layer.position

        position.x -= oldPoint.x
        position.x += newPoint.x

        position.y -= oldPoint.y
        position.y += newPoint.y

        layer.position = position
        layer.anchorPoint = point
    }
}
