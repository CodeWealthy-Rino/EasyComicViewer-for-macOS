//
//  Combobox.swift
//  MacComicReader
//
//  Created by CodeWealthy-Rino on 2020/01/05.
//  Copyright © 2020 CodeWealthy-Rino. All rights reserved.
//

import Foundation
import Cocoa
import SwiftUI

struct MyTextField: NSViewRepresentable {
    var currentVal : String
    
    var onEndEditing : ((String)->Void)?
    
    func makeCoordinator() -> Coordinator
    {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSTextField
    {
        let textField = NSTextField()
        textField.delegate = context.coordinator
        textField.isBordered = false
        return textField
    }
    
    func updateNSView(_ nsView: NSTextField, context: Self.Context)
    {
        nsView.stringValue = currentVal
    }
    
    final class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: MyTextField

        init(_ uiTextView: MyTextField)
        {
            self.parent = uiTextView
        }
        
        func controlTextDidChange(_ obj: Notification)
        {
            if let combobox = obj.object as? NSTextField
            {
                self.parent.currentVal = combobox.stringValue
            }
        }
        
        func controlTextDidEndEditing(_ obj: Notification) {
            self.parent.onEndEditing?(self.parent.currentVal )
        }
        
    
    }
}
