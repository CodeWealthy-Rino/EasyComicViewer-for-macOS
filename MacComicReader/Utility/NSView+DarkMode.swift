//
//  NSView+DarkMode.swift
//  MacComicReader
//
//  Created by CodeWealthy-Rino on 2020/09/15.
//  Copyright © 2020 CodeWealthy-Rino. All rights reserved.
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
