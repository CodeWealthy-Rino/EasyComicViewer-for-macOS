//
//  Setting.swift
//  MacComicReader
//
//  Created by CodeWealthy-Rino on 2021/01/04.
//  Copyright © 2021 CodeWealthy-Rino. All rights reserved.
//

import Foundation
import AppKit

enum MenuBehavior : Int
{
    case Normal = 0
    case ShowsOnMouseHover = 1
}

class Settings
{
    var menuBehavior : MenuBehavior
    {
        didSet
        {
            UserDefaults.standard.setValue(menuBehavior.rawValue, forKey: "menuBehavior")
        }
    }
    
    init()
    {
        if let menuBehavior = UserDefaults.standard.value(forKey: "menuBehavior") as? Int
        {
            self.menuBehavior = MenuBehavior(rawValue: menuBehavior)!
        }else{
            self.menuBehavior = MenuBehavior.Normal
        }
    }
    
    
}

