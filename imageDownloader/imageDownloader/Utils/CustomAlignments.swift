//
//  CustomAlignments.swift
//  imageDownloader
//
//  Created by nicolo.pasini on 22/09/24.
//

import SwiftUI

enum CenterToSuperViewCenterAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        context[VerticalAlignment.center]
    }
}

extension VerticalAlignment {
    static let centerToSuperViewCenterAlignment = Self(CenterToSuperViewCenterAlignment.self)
}

extension Alignment {
    static let superViewCenterAlignment = Self(
        horizontal: .center,
        vertical: .centerToSuperViewCenterAlignment
    )
}
