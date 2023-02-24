//
//  Color+Scheme.swift
//  MacComicReader
//
//  Created by RinoNanase on 2019/12/25.
//  Copyright © 2019 RinoNanase. All rights reserved.
//

import Foundation
import SwiftUI

extension Color {

    static let lightBackgroundColor = Color(white: 0.8)

    static let darkBackgroundColor = Color(white: 0.2)

    static func backgroundColor(for colorScheme: ColorScheme) -> Color {
        if colorScheme == .dark {
            return darkBackgroundColor
        } else {
            return lightBackgroundColor
        }
    }
}
