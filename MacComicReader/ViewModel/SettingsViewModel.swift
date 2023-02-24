//
//  SettingsViewModel.swift
//  MacComicReader
//
//  Created by RinoNanase on 2021/01/03.
//  Copyright © 2021 RinoNanase. All rights reserved.
//
import Foundation
import Cocoa


class SettingsViewModel: ObservableObject {

    var settings = Settings()
    
    @Published var menuBehavior : Int
    {
        didSet
        {
            settings.menuBehavior = MenuBehavior(rawValue: menuBehavior)!
        }
    }
        
    init ()
    {
        self.menuBehavior = settings.menuBehavior.rawValue
    }

    
}
