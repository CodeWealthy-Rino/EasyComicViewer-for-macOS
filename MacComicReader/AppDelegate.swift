//
//  AppDelegate.swift
//  MacComicReader
//
//  Created by RinoNanase on 2019/12/16.
//  Copyright © 2019 RinoNanase. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

    @IBOutlet weak var backShortCut: NSMenuItem!
    @IBOutlet weak var nextShortCut: NSMenuItem!
    
    var window: NSWindow!
    var mainWindowController = NSViewController()
    var mainWidowViewModel = MainWindowViewModel()
    var bookView : LibraryView?
    
    var libraryViewModel = LibraryViewModel()
    
    func enableBookShortCut()
    {
        backShortCut.isHidden = false
        nextShortCut.isHidden = false
    }
    
    func disableBookShortCut()
    {
        backShortCut.isHidden = true
        nextShortCut.isHidden = true
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        
        self.bookView = LibraryView(viewModel:libraryViewModel, mainWidowViewModel: mainWidowViewModel)
        let contentView = bookView

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 800),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentMinSize = NSMakeSize(800, 800)
        self.mainWidowViewModel.windowSizeX = window?.frame.size.width ?? 0.0
        self.mainWidowViewModel.windowSizeY = window?.frame.size.height ?? 0.0
        mainWindowController.view = NSHostingView(rootView: contentView)
        
        window.contentViewController = mainWindowController
        window.makeKeyAndOrderFront(nil)
        window.delegate = self
    }
        
    func windowDidEndLiveResize(_ notification: Notification) {
        self.mainWidowViewModel.windowSizeX = self.window?.frame.size.width ?? 0.0
        self.mainWidowViewModel.windowSizeY = self.window?.frame.size.height ?? 0.0
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply
    {
        Logger.print("applicationWillTerminate")
        bookView?.viewModel.save()
        bookView?.viewModel.finalize()
        return .terminateNow
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    @IBAction func onPushNext(_ sender: Any) {
        Logger.print("onPushNext")
        NotificationCenter.default.post(name: Notification.Name(rawValue:"onPushNext"), object: nil)
        
        if BookWindow.opendCount == 0
        {
            libraryViewModel.gotoLeft()
        }
    }
    
    @IBAction func onPushBack(_ sender: Any) {
        Logger.print("onPushBack")
        NotificationCenter.default.post(name: Notification.Name(rawValue:"onPushBack"), object: nil)
       
        
        if BookWindow.opendCount == 0
        {
            libraryViewModel.gotoRight()
        }
    }
    
}

