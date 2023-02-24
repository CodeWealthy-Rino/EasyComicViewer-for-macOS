//
//  FavoriteWindow.swift
//  MacComicReader
//
//  Created by CodeWealthy-Rino on 2020/11/08.
//  Copyright © 2020 CodeWealthy-Rino. All rights reserved.
//

import Foundation
import Cocoa
import SwiftUI

class FavoriteWindow: NSObject, NSWindowDelegate
{
    fileprivate var window : NSWindow?
    fileprivate var favoriteViewModel : FavioriteViewModel?
    
    var returnVal : String = ""
    
    func windowWillClose(_ notification: Notification) {
        NSApp.stopModal(withCode: .abort)
    }
        
    
    func runModal(_ book : Book) -> NSApplication.ModalResponse
    {
        self.favoriteViewModel = FavioriteViewModel(book : book)
        let contentView = FavoriteView(viewModel: self.favoriteViewModel!,
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
