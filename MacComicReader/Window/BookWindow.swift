//
//  BookWindow.swift
//  MacComicReader
//
//  Created by CodeWealthy-Rino on 2020/01/06.
//  Copyright © 2020 CodeWealthy-Rino. All rights reserved.
//

import Foundation
import Cocoa
import SwiftUI

class BookWindow: NSObject, NSWindowDelegate
{
    fileprivate var window : NSWindow?
    var viewModel : BookViewModel?
    static var canOpen = true
    
    static var opendCount = 0
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        BookWindow.opendCount -= 1
        if BookWindow.opendCount == 0
        {
            (NSApp.delegate as! AppDelegate).disableBookShortCut()
        }
        
        return true
    }
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onPushNext),
                                               name: Notification.Name(rawValue:"onPushNext"), object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onPushBack),
                                               name: Notification.Name(rawValue:"onPushBack"), object: nil)
        
    }
    
    deinit
    {
        print("deallocated")
    }
    
    let oprationQue  = OperationQueue()
    
    func openWindow(_ book : Book)
    {
        if BookWindow.canOpen == false
        {
            return
        }
        BookWindow.canOpen = false
        
        if book.type == .kZIP
        {
            _ = book.extractZIP()
        }
        
        book.dateLastOpend = Date()

        viewModel = BookViewModel(book: book)
        oprationQue.maxConcurrentOperationCount = 4
        let contentView = BookView(viewModel:viewModel!, thumbailCreateQueue: oprationQue)
        
        
        self.window = NSWindow(
                            contentRect: NSRect(x: 0, y: 0, width: 800, height: 800),
                            styleMask: [.titled, .closable, .resizable, .miniaturizable],
                            backing: .buffered, defer: false)
        self.window?.isReleasedWhenClosed = false
        self.window?.center()
        self.window?.setFrameAutosaveName("")
        self.window?.contentView = NSHostingView(rootView: contentView)
        self.window?.delegate = self
        self.window?.makeKeyAndOrderFront(self)
        self.window?.title = book.title
        BookWindow.opendCount += 1
        
        (NSApp.delegate as! AppDelegate).enableBookShortCut()

        
        self.perform(#selector(changeCanOpenFlag), with: nil, afterDelay: 3.0)
    }
    
    func windowWillClose(_ notification: Notification) {
        
    }
    
    
    @objc func changeCanOpenFlag()
    {
        BookWindow.canOpen = true
    }
    
    @objc func onPushNext(notification: NSNotification)
    {
        viewModel?.nextPage()
    }
    
    @objc func onPushBack(notification: NSNotification)
    {
        viewModel?.backPage()
    }

}
