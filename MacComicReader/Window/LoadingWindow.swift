//
//  LoadingWindow.swift
//  MacComicReader
//
//  Created by CodeWealthy-Rino on 2020/08/08.
//  Copyright © 2020 CodeWealthy-Rino. All rights reserved.
//

import Cocoa

class LoadingWindow: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    func openLoadingWindow (parent : NSWindow  ,process: () -> Void)
    {
        parent.beginSheet(self.window!, completionHandler: nil)
        
        process()
        
        parent.endSheet(self.window!)
    }
    
    
}
