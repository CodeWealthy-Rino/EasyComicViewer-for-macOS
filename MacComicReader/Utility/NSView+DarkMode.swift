//
//  NSView+DarkMode.swift
//  MacComicReader
//
//  Created by RinoNanase on 2020/09/15.
//  Copyright © 2020 RinoNanase. All rights reserved.
//

import Foundation
import AppKit

extension NSView {
    var isDarkMode: Bool {
        if #available(OSX 10.14, *) {
            if effectiveAppearance.name == .darkAqua {
                return true
            }
        }
        return false
    }
}
