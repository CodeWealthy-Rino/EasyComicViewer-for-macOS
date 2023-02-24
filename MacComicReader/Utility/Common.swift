//
//  Common.swift
//  MacComicReader
//
//  Created by RinoNanase on 2019/12/27.
//  Copyright © 2019 RinoNanase. All rights reserved.
//

import Foundation
import Cocoa

func dialogOKCancel(question: String, text: String) -> Bool
{
    let alert = NSAlert()
    alert.messageText = question
    alert.informativeText = text
    alert.alertStyle = .warning
    alert.addButton(withTitle: "OK")
    alert.addButton(withTitle: "Cancel")
    return alert.runModal() == .alertFirstButtonReturn
}

func dialogOK(_ text: String) -> Bool
{
    let alert = NSAlert()
    alert.alertStyle = .critical
    alert.messageText = text
    alert.addButton(withTitle: "OK")
    return alert.runModal() == .alertFirstButtonReturn
}

func dateToString(_ date : Date) -> String
{
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none

    return dateFormatter.string(from: date)
}


func isDarkMode() -> Bool
{
    let view = NSView()
    return view.isDarkMode
}
