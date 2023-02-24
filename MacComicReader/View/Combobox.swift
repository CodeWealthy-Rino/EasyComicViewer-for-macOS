//
//  Combobox.swift
//  MacComicReader
//
//  Created by RinoNanase on 2020/01/05.
//  Copyright © 2020 RinoNanase. All rights reserved.
//

import Foundation
import Cocoa
import SwiftUI

struct Combobox: NSViewRepresentable {
    @Binding var currentValue : String
    var allTags : Array<String>
    
    var onEndEditing : (()->Void)?
    
    func makeCoordinator() -> Coordinator
    {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSComboBox
    {
        let combobox = NSComboBox()
        combobox.delegate = context.coordinator
        return combobox
    }
    
    func updateNSView(_ nsView: NSComboBox, context: Self.Context)
    {
        nsView.removeAllItems()
        for tag in allTags
        {
            nsView.addItem(withObjectValue: tag)
        }
    }
    
    final class Coordinator: NSObject, NSComboBoxDelegate {
        var parent: Combobox

        init(_ uiTextView: Combobox)
        {
            self.parent = uiTextView
        }
        
        func controlTextDidChange(_ obj: Notification)
        {
            if let combobox = obj.object as? NSComboBox
            {
                self.parent.currentValue = combobox.stringValue
            }
        }
        
        func controlTextDidEndEditing(_ obj: Notification) {
            self.parent.onEndEditing?()
        }
        
        
        func comboBoxSelectionDidChange(_ obj: Notification)
        {
            
            if let combobox = obj.object as? NSComboBox
            {
                if combobox.indexOfSelectedItem >= 0 && combobox.indexOfSelectedItem < combobox.numberOfItems
                {
                    if let selectedValue = combobox.objectValues[combobox.indexOfSelectedItem] as? String
                    {
                        self.parent.currentValue = selectedValue
                    }
                }
            }
        }
    }
}
