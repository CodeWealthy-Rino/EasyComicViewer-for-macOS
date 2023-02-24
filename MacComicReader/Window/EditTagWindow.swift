//
//  AddTagWindow.swift
//  MacComicReader
//
//  Created by CodeWealthy-Rino on 2020/01/04.
//  Copyright © 2020 CodeWealthy-Rino. All rights reserved.
//

import Cocoa
import SwiftUI

class EditTagWindow: NSObject, NSWindowDelegate
{
    fileprivate var window : NSWindow?
    fileprivate var tagViewModel : TagViewModel?
    
    func windowWillClose(_ notification: Notification) {
        tagViewModel!.apply()
        NSApp.stopModal(withCode: .abort)
    }
    
    
    func runModal(_ book : Book, allTags : Array<String>)
    {
        self.tagViewModel = TagViewModel(book : book)
        let contentView = EditTagView(tagViewModel: self.tagViewModel!, allTags: allTags)

        self.window = NSWindow(
                            contentRect: NSRect(x: 0, y: 0, width: 400, height: 600),
                            styleMask: [.titled, .closable],
                            backing: .buffered, defer: false)
        self.window?.isReleasedWhenClosed = false
        self.window?.center()
        self.window?.setFrameAutosaveName("Add Tag")
        self.window?.contentView = NSHostingView(rootView: contentView)
        self.window?.delegate = self
        NSApp.runModal(for: window!)
    }

}
