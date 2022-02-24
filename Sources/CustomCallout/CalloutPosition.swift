//
//  CalloutPosition.swift
//  
//
//  Created by James Randolph on 2/23/22.
//

import UIKit

struct CalloutPosition {

    enum PreferredPlacement {
        case top, bottom, horizontal
    }

    enum ResolvedPlacement {
        case top, bottom, left, right, unknown
    }

    static let unknown = CalloutPosition(frame: .zero, placement: .unknown, arrowOffset: 0)

    var frame: CGRect

    var placement: ResolvedPlacement

    var arrowOffset: CGFloat
}
