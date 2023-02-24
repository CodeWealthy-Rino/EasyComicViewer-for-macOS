//
//  FavoriteWindow.swift
//  MacComicReader
//
//  Created by RinoNanase on 2020/11/08.
//  Copyright © 2020 RinoNanase. All rights reserved.
//

import Foundation
import Cocoa
import SwiftUI

class SettingsWindow: NSObject, NSWindowDelegate
{
    fileprivate var window : NSWindow?
    fileprivate var settingsViewModel : SettingsViewModel?
    
    var returnVal : String = ""
    
    func windowWillClose(_ notification: Notification) {
        NSApp.stopModal(withCode: .abort)
    }
        
    
    func runModal() -> NSApplication.ModalResponse
    {
        self.settingsViewModel = SettingsViewModel()
        let contentView = SettingsView(viewModel: self.settingsViewModel!,
                                       onClose: {val in
                                            self.returnVal = val
                                            self.window?.close()
                                            NSApp.stopModal(withCode: .OK)
                                       })

        self.window = NSWindow(
                            contentRect: NSRect(x: 0, y: 0, width: 400, height: 600),
                            styleMask: [.titled, .closable],
                            backing: .buffered, defer: false)
        self.window?.isReleasedWhenClosed = false
        self.window?.center()
        self.window?.setFrameAutosaveName("Favorite window")
        self.window?.contentView = NSHostingView(rootView: contentView)
        self.window?.delegate = self
        
        
        
        return NSApp.runModal(for: window!)
    }

}
