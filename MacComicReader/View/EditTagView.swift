//
//  AddTagView.swift
//  MacComicReader
//
//  Created by CodeWealthy-Rino on 2020/01/04.
//  Copyright © 2020 CodeWealthy-Rino. All rights reserved.
//

import Foundation
import SwiftUI

struct EditTagView: View  {
    
    @State var tagName: String = ""
    @ObservedObject var tagViewModel : TagViewModel
    var allTags : Array<String>

    var body: some View
    {
        VStack
        {
            Text(verbatim: "EDIT_TAGS".toL)
            
            List {
                ForEach(self.tagViewModel.tags, id: \.self) { tag in
                    HStack{
                        Tag(tag : tag)
                        Button(action: {
                            self.tagViewModel.removeTag(tag)
                        })
                        {
                            Image(nsImage: NSImage(imageLiteralResourceName: NSImage.touchBarDeleteTemplateName))
                        }
                    }
                }.onMove(perform: move)
            }
            
            HStack {
                Combobox(currentValue: $tagName, allTags: allTags)
                Button(action: {
                    self.tagViewModel.addTag(self.tagName)
                }){
                    Text("ADD".toL)
                }.disabled(tagName.count  == 0)
            }
        }.padding()
    }
        
    func move(from source: IndexSet, to destination: Int) {
        self.tagViewModel.move(from: source, to: destination)
    }
}
